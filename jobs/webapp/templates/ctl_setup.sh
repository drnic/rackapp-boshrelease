#!/usr/bin/env bash

# Setup env vars and folders for the webapp_ctl script
# This helps keep the webapp_ctl script as readable
# as possible

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

source /var/vcap/jobs/webapp/bin/ctl_utils.sh
redirect_output 'webapp'


export HOME=${HOME:-/home/vcap}

# Add all packages' /bin & /sbin into $PATH
for package_bin_dir in $(ls -d /var/vcap/packages/*/{,s}bin)
do
  export PATH=${package_bin_dir}:$PATH
done

# Setup log, run and tmp folders

RUN_DIR=/var/vcap/sys/run/webapp
LOG_DIR=/var/vcap/sys/log/webapp
TMPDIR=/var/vcap/sys/tmp/webapp
for dir in $RUN_DIR $LOG_DIR $TMPDIR
do
  mkdir -p ${dir}
  chown vcap:vcap ${dir}
done

export C_INCLUDE_PATH=/var/vcap/packages/mysqlclient/include/mysql:/var/vcap/packages/sqlite/include:/var/vcap/packages/libpq/include
export LIBRARY_PATH=/var/vcap/packages/mysqlclient/lib/mysql:/var/vcap/packages/sqlite/lib:/var/vcap/packages/libpq/lib

PIDFILE=$RUN_DIR/webapp.pid
