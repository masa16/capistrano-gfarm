# Deploy Gfarm file system with Capistrano

* task definition: [gfarm_task.rb](https://github.com/masa16/capistrano-gfarm/blob/master/config/deploy/gfarm_task.rb)
* example settings: [ipmu.rb](https://github.com/masa16/capistrano-gfarm/blob/master/config/deploy/ipmu.rb)
  * Configure a private Gfarm filesystem by a non privileged user.
  * backend DB: PostgreSQL


# Task List

```
download     # download source
build        # build & install Gfarm programs
setup        # setup:gfmd & setup:gfsd
setup:gfmd   # setup Metadata Server (MDS)
setup:gfsd   # setup File System Node (FSN)

start        # start:gfmd & start:gfsd
start:gfmd   # start Metadata Server (MDS)
start:gfsd   # start File System Node (FSN)

stop         # stop:gfmd & stop:gfsd
stop:gfmd    # stop Metadata Server (MDS)
stop:gfsd    # stop File System Node (FSN)
```

# Example

```
$ cd this-repo-top
$ cap ipmu build

$ cap ipmu setup
$ cap ipmu setup:gfmd
$ cap ipmu setup:gfsd

$ cap ipmu start
$ cap ipmu start:gfmd
$ cap ipmu start:gfsd

$ cap ipmu stop
$ cap ipmu stop:gfmd
$ cap ipmu stop:gfsd
```
