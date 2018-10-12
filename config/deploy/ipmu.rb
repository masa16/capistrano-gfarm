set :gfarm_version, "2.7.11"
set :gfarm2fs_version, "1.2.11"
set :gfarm_suffix,"2711"

set :build_host, "mds2-ib"
set :gfmd_host, "mds2-ib"
set :build_path, "/tmp/tanakatkb_build"
set :install_path, "/home/tanakatkb/local/gfarm/#{fetch(:gfarm_suffix)}"

role :build, fetch(:build_host)
role :gfmd, fetch(:gfmd_host)
role :gfsd, (1..60).map{|i| "ansys%02d-ib" % i}
role :client, ["fe"]+(1..60).map{|i| "ansys%02d-ib" % i}

set :gfmd_path, "/datassd/tanakatkb/gfarm/"+fetch(:gfarm_suffix)
set :gfmd_db_path, "/datassd/tanakatkb/gfarm/"+fetch(:gfarm_suffix)+"/db"
set :gfsd_path, "/gfarm/tanakatkb/gfarm/"+fetch(:gfarm_suffix)
set :gfsd_spool_path, "/gfarm/tanakatkb/gfarm/"+fetch(:gfarm_suffix)+"/spool"
set :mount_point, "/tmp/tanakatkb"

set :pgsql_port, 20601
set :gfmd_port, 20602
set :gfsd_port, 20603

set :build_gfarm_options,
{
# Installation directories:
  prefix:fetch(:install_path), # =PREFIX  install architecture-independent files in PREFIX [/usr/local]
  "exec-prefix":nil,           # =EPREFIX  install architecture-dependent files in EPREFIX [PREFIX]

# Fine tuning of the installation directories:
  bindir:nil,            # user executables [EPREFIX/bin]
  sbindir:nil,           # system admin executables [EPREFIX/sbin]
  libexecdir:nil,        # program executables [EPREFIX/libexec]
  sysconfdir:nil,        # read-only single-machine data [PREFIX/etc]
  sharedstatedir:nil,    # modifiable architecture-independent data [PREFIX/com]
  localstatedir:nil,     # modifiable single-machine data [PREFIX/var]
  libdir:nil,            # object code libraries [EPREFIX/lib]
  includedir:nil,        # C header files [PREFIX/include]
  oldincludedir:nil,     # C header files for non-gcc [/usr/include]
  datarootdir:nil,       # read-only arch.-independent data root [PREFIX/share]
  datadir:nil,           # read-only architecture-independent data [DATAROOTDIR]
  infodir:nil,           # info documentation [DATAROOTDIR/info]
  localedir:nil,         # locale-dependent data [DATAROOTDIR/locale]
  mandir:nil,            # man documentation [DATAROOTDIR/man]
  docdir:nil,            # documentation root [DATAROOTDIR/doc/gfarm]
  htmldir:nil,           # html documentation [DOCDIR]
  dvidir:nil,            # dvi documentation [DOCDIR]
  pdfdir:nil,            # pdf documentation [DOCDIR]
  psdir:nil,             # ps documentation [DOCDIR]

# System types:
  build:nil,             # configure for building on BUILD [guessed]
  host:nil,              # cross-compile to build programs to run on HOST [BUILD]

# Optional Features:
  "disable-option-checking":nil, # ignore unrecognized --enable/--with options
  # disable-FEATURE           # do not include FEATURE (same as --enable-FEATURE=no)
  # enable-FEATURE[=ARG]      # include FEATURE [ARG=yes]
  "disable-openmp":nil,       # do not use OpenMP
  "enable-shared":nil,        # [=PKGS]  # build shared libraries [default=yes]
  "enable-static":nil,        # [=PKGS]  # build static libraries [default=yes]
  "enable-fast-install":nil,  # [=PKGS]
                              # optimize for fast installation [default=yes]
  "disable-libtool-lock":nil, # avoid locking (might break parallel builds)
  "enable-voms":nil,          # enable VOMS synchronization feature
                              # [default=disable]
  "enable-xmlattr":nil,       # support XML extended attributes and XPath search
                              # [default=disable]
  "enable-linuxkernel":nil,   # support Linux kernel module utils.[[default=no]]

# Optional Packages:
  # with-PACKAGE[=ARG]        # use PACKAGE [ARG=yes]
  # without-PACKAGE           # do not use PACKAGE (same as --with-PACKAGE=no)
  "with-pic":nil, # [=PKGS]   # try to use only PIC/non-PIC objects [default=use both]
  "with-gnu-ld":nil,          # assume the C compiler uses GNU ld [default=no]
  "with-sysroot":nil,         # Search for dependent libraries within DIR
                              # (or the compiler's sysroot if not specified).
  "with-pthread":nil,         # =PTHREAD_ROOT # pthread root directory [default=/usr]
  "without-pthread":nil,      # disable pthread support
  "with-openssl":nil,         # =OpenSSL_ROOT # openssl root directory [default=/usr]
  "with-globus-static":nil,   # link static version of globus libraries instead of shared version
                              # [default=disable]
  "with-globus-flavor":nil,   # =FLAVOR # globus flavor name [default=guessed]
  "with-globus-libdir":nil,   # globus library directory [default=guessed]
  "with-globus":nil,          # =GLOBUS_ROOT # globus root directory [default=disable]
  "without-mtsafe-netdb":nil, # getaddrinfo(3) and getnameinfo(3) are MT-Safe? [default=yes]
  "with-infiniband":true,     # [=InfiniBand_ROOT] support InfiniBand RDMA between client and gfsd
                              # [default=/usr]
  "with-openldap":nil,        # =OpenLDAP_ROOT # openldap root directory [default=guessed]
  "without-openldap":nil,     # disable openldap
  "with-postgresql":nil,      # =PostgreSQL_ROOT # PostgreSQL root directory [default=guessed]
  "without-postgresql":nil,   # disable PostgreSQL
  "with-ib-symvers":nil,      # =PATH # extra InfiniBand Module.symvers,
                              # with --enable-linuxkernel.
                              # if you are not sure, run linux/config/findIBmodules
  "with-ib-include":nil,      # extra InfiniBand headers,
                              # with --enable-linuxkernel.
                              # if you are not sure, run linux/config/findIBmodules
  "with-private-srcdir":nil,  # private source directory
}

set :build_gfarm2fs_options,
{
# Installation directories:
  prefix:fetch(:install_path), # =PREFIX install architecture-independent files in PREFIX [/usr/local]
  "exec-prefix":nil,           # =EPREFIX install architecture-dependent files in EPREFIX [PREFIX]

# Fine tuning of the installation directories:
  bindir:nil,            # user executables [EPREFIX/bin]
  sbindir:nil,           # system admin executables [EPREFIX/sbin]
  libexecdir:nil,        # program executables [EPREFIX/libexec]
  sysconfdir:nil,        # read-only single-machine data [PREFIX/etc]
  sharedstatedir:nil,    # modifiable architecture-independent data [PREFIX/com]
  localstatedir:nil,     # modifiable single-machine data [PREFIX/var]
  libdir:fetch(:install_path)+"/lib",            # object code libraries [EPREFIX/lib]
  includedir:nil,        # C header files [PREFIX/include]
  oldincludedir:nil,     # C header files for non-gcc [/usr/include]
  datarootdir:nil,       # read-only arch.-independent data root [PREFIX/share]
  datadir:nil,           # read-only architecture-independent data [DATAROOTDIR]
  infodir:nil,           # info documentation [DATAROOTDIR/info]
  localedir:nil,         # locale-dependent data [DATAROOTDIR/locale]
  mandir:nil,            # man documentation [DATAROOTDIR/man]
  docdir:nil,            # documentation root [DATAROOTDIR/doc/gfarm2fs]
  htmldir:nil,           # html documentation [DOCDIR]
  dvidir:nil,            # dvi documentation [DOCDIR]
  pdfdir:nil,            # pdf documentation [DOCDIR]
  psdir:nil,             # ps documentation [DOCDIR]

# Program names:
  "program-prefix":nil, # =PREFIX            # prepend PREFIX to installed program names
  "program-suffix":nil, # =SUFFIX            # append SUFFIX to installed program names
  "program-transform-name":nil, # =PROGRAM   # run sed PROGRAM on installed program names

# System types:
  build:nil, # =BUILD     configure for building on BUILD [guessed]
  host:nil, # =HOST       cross-compile to build programs to run on HOST [BUILD]

# Optional Features:
  "disable-option-checking":nil, #  ignore unrecognized --enable/--with options
  # disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  # enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  "enable-silent-rules":nil,     # less verbose build output (undo: "make V=1")
  "disable-silent-rules":nil,    # verbose build output (undo: "make V=0")
  "enable-maintainer-mode":nil,  # enable make rules and dependencies not useful (and
                                 # sometimes confusing) to the casual installer
  "disable-largefile":nil,       # omit support for large files
  "enable-dependency-tracking":nil, # do not reject slow dependency extractors
  "disable-dependency-tracking":nil, # speeds up one-time build
  "enable-shared":nil, #[=PKGS]  # build shared libraries [default=yes]
  "enable-static":nil, #[=PKGS]  # build static libraries [default=yes]
  "enable-fast-install":nil, #[=PKGS]
                        # optimize for fast installation [default=yes]
  "disable-libtool-lock":nil,    # avoid locking (might break parallel builds)
  "disable-xattr":nil,           # disable extended attribute
  "disable-acl":true,            # disable extended ACL

# Optional Packages:
  # with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  # without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  "with-pic":nil, #[=PKGS]       # try to use only PIC/non-PIC objects [default=use both]
  "with-gnu-ld":nil,             # assume the C compiler uses GNU ld [default=no]
  "with-sysroot":nil,            #=DIR Search for dependent libraries within DIR
                                 # (or the compiler's sysroot if not specified).
  "with-gfarm":fetch(:install_path), #=GFARM_ROOT Gfarm root directory [[/usr]]
  "with-private-srcdir":nil,     #=DIR # private source directory
}

set :config_gfarm_options,
{
  prefix:fetch(:gfmd_path),
  f:true, # Force overwriting an existing set up.
  #b:"none", # metadata backend
  b:"postgresql", # metadata backend
  l:fetch(:gfmd_db_path), # metadata directory    /var/gfarm-pgsql
  L:nil,   # metadata log directory    /var/gfarm-pgsql/pg_xlog
  U:nil,   # postgresql admin user     miles
  W:nil,   # postgresql admin password (auto generated)
  u:nil,   # postgresql user           gfarm
  w:nil,   # postgresql password       (auto generated)
  P:nil,   # postgresql prefix         /usr
  V:nil,   # postgresql version        9.2
  X:nil,   # postgresql XML supported  no
  r:nil,   # metadata replication      no
  h:nil,   # metaserver hostname
  A:"tanakatkb", # matadata admin user
  D:nil,   # matadata admin dn
  p:fetch(:pgsql_port), # portmaster port           10602
  m:fetch(:gfmd_port), # gfmd port                 601
  a:nil,   # auth type                 sharedsecret
  d:nil,   # Enable checksum calculation and specify the digest type of the checksum.
  j:nil,   # Specify a path to the directory where gfmd puts journal files.
           # This option takes an effect only when metadata replication is enabled by -r option.
  S:true,  # Enable the private mode.
  N:nil,   # Do not start gfmd or the backend database.
}

set :gfmd_conf_addition,"
max_open_files 16384
metadb_server_dbq_size 134217728
network_receive_timeout 120
#metadb_server_long_term_lock_type mutex
"

set :config_gfsd_options,
{
  prefix:fetch(:gfsd_path),
  f:true,  # Force overwriting an existing set up.
  h:nil,   # hostname
  l:nil,   # listen address               [-l]: (all local IP addresses)
  a:nil,   # architecture                 [-a]: x86_64-centos6.5-linux
  p:fetch(:gfsd_port), # port
  n:nil,   # ncpu
  S:true,  # Enable the private mode.
  N:nil,   # Do not start gfsd.
}
