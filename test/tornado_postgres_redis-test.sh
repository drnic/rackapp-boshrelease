#!/usr/bin/env roundup

describe "run RedisLive with postgresql to monitor Redis DBs"

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
# set -x

[ "$(whoami)" != 'root' ] && ( echo ERROR: run as root user; exit 1 )

cd /vagrant/ # need to hardcode as roundup overrides $0
release_path=$(pwd)
scripts=${release_path}/scripts

rm -rf /tmp/before_all_run_already

before_all() {
  echo "|"
  echo "| Stopping any existing jobs"
  echo "|"
  ${scripts}/stop

  echo "|"
  echo "| Deleting databases"
  echo "|"
  rm -rf /var/vcap/store

  # update deployment with example properties
  example=${release_path}/examples/tornado_postgres_redis.yml
  ${scripts}/update ${example}

  # wait for postgres to setup DB & webapp to start
  sleep 5
  
  # show last 20 processes (for debugging if test fails)
  ps ax | tail -n 20
}

# before() is only hook into roundup
# TODO add before_all() to roundup
before() {
  if [ ! -f /tmp/before_all_run_already ]
  then
    before_all
    touch /tmp/before_all_run_already
  fi
}

it_runs_tornado() {
  expected='tornado'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_runs_postgres() {
  expected='postgres -D /var/vcap/store/postgres -h 127.0.0.1 -p 5432'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_runs_redis() {
  expected='bin/redis'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}
