require_relative "gfarm_util"


task :download do
  gfarm_tarball = "gfarm-#{fetch(:gfarm_version)}.tar.gz"
  gfarm2fs_tarball = "gfarm2fs-#{fetch(:gfarm2fs_version)}.tar.gz"

  file gfarm_tarball do |task|
    run_locally do
      url = ["https://sourceforge.net/projects/gfarm/files/gfarm_v2",
             fetch(:gfarm_version),task.name,"download"].join("/")
      http_download(url,task.name)
    end
  end

  file gfarm2fs_tarball do |task|
    run_locally do
      url = ["https://sourceforge.net/projects/gfarm/files/gfarm2fs",
             fetch(:gfarm2fs_version),task.name,"download"].join("/")
      http_download(url,task.name)
    end
  end

  invoke gfarm_tarball
  invoke gfarm2fs_tarball
end


task :build => :download do

  on roles(:build) do |host|
    path = fetch(:build_path)
    execute :mkdir,"-p",path

    gfarm_tarball = "gfarm-#{fetch(:gfarm_version)}.tar.gz"
    gfarm2fs_tarball = "gfarm2fs-#{fetch(:gfarm2fs_version)}.tar.gz"

    info up_path = remote_env(File.join(path,gfarm_tarball))
    upload!(gfarm_tarball, up_path)

    info up_path = remote_env(File.join(path,gfarm2fs_tarball))
    upload!(gfarm2fs_tarball, up_path)

    within path do
      execute :rm,"-rf","gfarm-#{fetch(:gfarm_version)}"
      execute :tar,:xf,gfarm_tarball
      execute :rm,"-rf","gfarm2fs-#{fetch(:gfarm2fs_version)}"
      execute :tar,:xf,gfarm2fs_tarball
    end

    within "#{path}/gfarm-#{fetch(:gfarm_version)}" do
      execute "./configure",parse_option(:build_gfarm_options,"=")
      execute :make
      execute :make,:install
    end

    within "#{path}/gfarm2fs-#{fetch(:gfarm2fs_version)}" do
      execute "./configure",parse_option(:build_gfarm2fs_options,"=")
      execute :make
      execute :make,:install
    end
  end
end


namespace :setup do
  task :gfmd do
    on roles(:gfmd) do |host|
      top = remote_env(fetch(:gfmd_path))
      etc = File.join(top,'etc')

      execute :rm,'-rf',etc
      execute :rm,'-rf',File.join(top,'var')
      execute :rm,'-rf',fetch(:gfmd_db_path)

      execute fetch(:install_path)+"/bin/config-gfarm",
        parse_option(:config_gfarm_options),
        "-h",host.hostname,
        "-A",capture(:echo,"$USER")

      download! File.join(etc,'gfarm2.conf'),'.'
      download! File.join(etc,'gfsd.conf'),'.'
      download! File.join(etc,'usermap'),'.'

      # additional option to gfarm2.conf
      if addition = fetch(:gfarm2_conf_addition)
        open('gfarm2.conf','at'){|f| f.puts("",addition)}
        upload! 'gfarm2.conf',etc
      end

      # copy gfarm2.conf to install_path
      inst_etc = remote_env(File.join(fetch(:install_path),'etc'))
      execute :mkdir,"-p",inst_etc
      upload! 'gfarm2.conf',inst_etc
      upload! 'usermap',inst_etc

      # fix local_user_map in gfsd.conf
      if fetch(:gfmd_path) != fetch(:gfsd_path)
        x = nil
        open('gfsd.conf','rt'){|f| x = f.read}
        y = remote_env(fetch(:gfmd_path))
        z = remote_env(fetch(:gfsd_path))
        x.sub!(/#{Regexp.quote(y)}/,z)
        open('gfsd.conf','wt'){|f| f.write(x)}
        upload! 'gfsd.conf',inst_etc
      end

      # additional option to gfmd.conf
      if addition = fetch(:gfmd_conf_addition)
        download! File.join(etc,'gfmd.conf'),'.'
        open('gfmd.conf','at'){|f| f.puts("",addition)}
        upload! 'gfmd.conf',etc
        execute File.join(etc,'init.d','gfmd'),:restart
      end
    end
    print_process(:gfmd,"gfmd")
  end

  task :gfsd do
    on roles(:gfsd), in: :parallel, limit:8 do |host|
      etc = remote_env(File.join(fetch(:gfsd_path),'etc'))
      execute :rm,"-rf",etc
      execute :mkdir,"-p",etc
      upload! 'gfsd.conf',etc
      upload! 'usermap',etc
      path = fetch(:gfsd_spool_path)
      execute :mkdir,"-p",path
      execute fetch(:install_path)+"/bin/config-gfsd",
        parse_option(:config_gfsd_options),
        "-h",host.hostname,
        fetch(:gfsd_spool_path)
    end
    print_process(:gfsd,"gfsd")
  end
end

task :setup do
  invoke "setup:gfmd"
  invoke "setup:gfsd"
end


namespace :stop do
  task :pgsql do
    on roles(:gfmd) do |host|
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfarm-pgsql'),:stop
    end
    print_process(:gfmd,"pgsql")
  end
  task :postgres => :pgsql
  task :postgresql => :pgsql

  task :gfmd do
    on roles(:gfmd) do |host|
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfmd'),:stop
    end
    print_process(:gfmd,"gfmd")
  end
  task :mds => :gfmd

  task :gfsd do
    on roles(:gfsd), in: :parallel, limit:32 do |host|
      execute File.join(fetch(:gfsd_path),'etc','init.d','gfsd'),:stop
    end
    print_process(:gfsd,"gfsd")
  end
  task :fsn => :gfsd
end

task :stop do
  invoke "stop:gfsd"
  invoke "stop:gfmd"
  invoke "stop:pgsql"
end


namespace :start do
  task :pgsql do
    on roles(:gfmd) do |host|
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfarm-pgsql'),:start
    end
    print_process(:gfmd,"pgsql")
  end
  task :postgres => :pgsql

  task :gfmd do
    on roles(:gfmd) do |host|
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfmd'),:start
    end
    print_process(:gfmd,"gfmd")
  end
  task :mds => :gfmd

  task :gfsd do
    on roles(:gfsd), in: :parallel, limit:16 do |host|
      execute File.join(fetch(:gfsd_path),'etc','init.d','gfsd'),:start
    end
    print_process(:gfsd,"gfsd")
  end
  task :fsn => :gfsd
end

task :start do
  invoke "start:pgsql"
  invoke "start:gfmd"
  invoke "start:gfsd"
end


task :mount do
  on roles(:client), in: :parallel, limit:8 do |host|
    execute :mkdir,"-p",fetch(:mount_point)
    execute :gfarm2fs,"-o","direct_io",fetch(:mount_point)
  end
  print_process(:client,"gfarm2fs")
end

task :umount do
  on roles(:client), in: :parallel, limit:8 do |host|
    execute :fusermount,"-u",fetch(:mount_point)
    execute :rmdir,fetch(:mount_point)
  end
  print_process(:client,"gfarm2fs")
end
