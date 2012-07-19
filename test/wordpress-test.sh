#!/usr/bin/env roundup

describe "run wordpress webapp with postgresql"

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

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
  echo "| Deleting postgres databases"
  echo "|"
  rm -rf /var/vcap/store

  # update deployment with example properties
  example=${release_path}/examples/nginx_wordpress.yml
  ${scripts}/update ${example}

  # wait for postgres to setup DB & webapp to start
  sleep 15
  
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

it_runs_webapp_behind_nginx() {
  expected='sbin/nginx -c /var/vcap/jobs/webapp/config/nginx.conf'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_runs_webapp_using_php_fpm() {
  expected='php-fpm: master process (/var/vcap/jobs/phpfpm/config/php-fpm.conf)'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_runs_postgres() {
  expected='postgres -D /var/vcap/store/postgres -h 127.0.0.1 -p 5432'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_responds_to_root_path() {
  test $(curl -s -i http://localhost:80 | grep 'HTTP/1.1 200 OK' | wc -l) = 1
}

it_restarted_nginx() {
  test $(cat /var/vcap/sys/log/phpfpm/nginx.stderr.log | wc -l) = 0
}