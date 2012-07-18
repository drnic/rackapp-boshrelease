#!/usr/bin/env roundup

describe "jobs setup & run processes"

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

[ "$(whoami)" != 'root' ] && ( echo ERROR: run as root user; exit 1 )

cd /vagrant/ # need to hardcode as roundup overrides $0
release_path=$(pwd)
scripts=${release_path}/scripts

before() {
  echo "|"
  echo "| Stopping any existing jobs"
  echo "|"
  ${scripts}/stop

  echo "|"
  echo "| Deleting postgres databases"
  echo "|"
  rm -rf /var/vcap/store
}

# puma_migrations_postgres.yml
it_pg_and_puma_running() {
  example=${release_path}/examples/puma_migrations_postgres.yml
  ${scripts}/update ${example}

  expected_puma='puma --pidfile /var/vcap/sys/run/webapp/webapp.pid -p 5000 -t 0:20'
  expected_postgres='postgres -D /var/vcap/store/postgres -h 127.0.0.1 -p 5432'

  sleep 8 # wait for postgres to setup DB & webapp to start

  ps ax
  echo "show puma:"
  ps ax | grep "${expected_puma}" | grep -v 'grep'
  echo "show postgres:"
  ps ax | grep "${expected_postgres}" | grep -v 'grep'
  echo "now the tests..."

  # test that there is one 'ps ax' line that matches for each expected_* above
  test $(ps ax | grep "${expected_puma}" | grep -v 'grep' | wc -l) = 1
  test $(ps ax | grep "${expected_postgres}" | grep -v 'grep' | wc -l) = 1
}