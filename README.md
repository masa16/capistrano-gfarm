# Deploy Gfarm file system with Capistrano

* Task definition: [gfarm_task.rb](https://github.com/masa16/capistrano-gfarm/blob/master/config/deploy/gfarm_task.rb)
* Example settings: [ipmu.rb](https://github.com/masa16/capistrano-gfarm/blob/master/config/deploy/ipmu.rb)
  * Configure a private Gfarm filesystem by a non privileged user.
  * Backend DB: PostgreSQL

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

stop         # stop:gfsd & stop:gfmd
stop:gfsd    # stop File System Node (FSN)
stop:gfmd    # stop Metadata Server (MDS)
```

# Example

```
$ cd this-repo-top

$ cap ipmu build

$ cap ipmu setup

$ cap ipmu stop

$ cap ipmu start
```
