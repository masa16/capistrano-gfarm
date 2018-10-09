require 'net/http'

def http_download(uri_str, file_name, limit:10)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  info "connecting #{uri_str}"
  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess
    info "saving to #{file_name}"
    open(file_name, "wb") do |file|
      file.write(response.body)
    end
    response
  when Net::HTTPRedirection
    http_download(response['location'], file_name, limit:limit-1)
  else
    response.value
  end
end

def parse_option(opt_key,sep=' ')
  fetch(opt_key).map do |k,v|
    k = k.to_s
    if k.size == 1
      m = "-"
    elsif k.size > 1
      m = "--"
    else
      raise ArgumentError,"Invalid option"
    end
    case v
    when NilClass
      nil
    when FalseClass
      [m,k,sep,"no"].join
    when TrueClass
      [m,k].join
    else
      [m,k,sep,v].join
    end
  end.compact
end

def remote_env(str)
  capture(:echo,"\"#{str}\"")
end

def print_process(role)
  output = {}
  on roles(role), in: :parallel do |host|
    output[host] = "[#{host.hostname}]\n#{capture(:ps,"-x")}"
  end
  roles(role).each{|host| puts output[host]}
end


set :gfarm_tarball, "gfarm-#{fetch(:gfarm_version)}.tar.gz"
set :gfarm2fs_tarball, "gfarm2fs-#{fetch(:gfarm2fs_version)}.tar.gz"

file fetch(:gfarm_tarball) do |task|
  run_locally do
    url = ["https://sourceforge.net/projects/gfarm/files/gfarm_v2",
           fetch(:gfarm_version),task.name,"download"].join("/")
    http_download(url,task.name)
  end
end

file fetch(:gfarm2fs_tarball) do |task|
  run_locally do
    url = ["https://sourceforge.net/projects/gfarm/files/gfarm2fs",
           fetch(:gfarm_version),task.name,"download"].join("/")
    http_download(url,task.name)
  end
end

task download:[fetch(:gfarm_tarball),fetch(:gfarm2fs_tarball)]

task :build => :download do
  on roles(:build) do |host|
    path = fetch(:build_path)
    execute :mkdir,"-p",path

    file = fetch(:gfarm_tarball)
    up_path = remote_env("#{path}/#{file}")
    info up_path
    upload!(file, up_path)

    file = fetch(:gfarm2fs_tarball)
    up_path = remote_env("#{path}/#{file}")
    info up_path
    upload!(file, up_path)

    within path do
      execute :rm,"-rf","gfarm-#{fetch(:gfarm_version)}"
      execute :tar,:xf,fetch(:gfarm_tarball)
      execute :rm,"-rf","gfarm2fs-#{fetch(:gfarm2fs_version)}"
      execute :tar,:xf,fetch(:gfarm2fs_tarball)
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
    print_process(:gfmd)
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
    print_process(:gfsd)
  end
end

task :setup do
  invoke "setup:gfmd"
  invoke "setup:gfsd"
end


namespace :stop do
  task :gfmd do
    on roles(:gfmd) do |host|
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfmd'),:stop
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfarm-pgsql'),:stop
    end
    print_process(:gfmd)
  end
  task :gfsd do
    on roles(:gfsd), in: :parallel, limit:8 do |host|
      execute File.join(fetch(:gfsd_path),'etc','init.d','gfsd'),:stop
    end
    print_process(:gfsd)
  end
end

task :stop do
  invoke "stop:gfsd"
  invoke "stop:gfmd"
end


namespace :start do
  task :gfmd do
    on roles(:gfmd) do |host|
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfarm-pgsql'),:start
      execute File.join(fetch(:gfmd_path),'etc','init.d','gfmd'),:start
    end
    print_process(:gfmd)
  end
  task :gfsd do
    on roles(:gfsd), in: :parallel, limit:8 do |host|
      execute File.join(fetch(:gfsd_path),'etc','init.d','gfsd'),:start
    end
    print_process(:gfsd)
  end
end

task :start do
  invoke "start:gfmd"
  invoke "start:gfsd"
end
