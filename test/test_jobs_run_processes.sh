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

# it_regexp() {
#   output="Hello from your rack app is awesome"
#   expected="Hello from your rack app"
#   if [[ ${output} =~ ${expected} ]]; then true; else false; fi
# }

# rackonly.yml
Xit_rackonly_running() {
  example=${release_path}/examples/rackonly.yml
  ${scripts}/update ${example}

  expected_webapp='rackup -D -P /var/vcap/sys/run/webapp/webapp.pid -p 5000'
  no_expected_postgres='postgres'

  # wait for webapp to start
  sleep 6
  
  # show last 20 processes (for debugging if test fails)
  ps ax | tail -n 20
  
  test $(ps ax | grep "${expected_webapp}" | grep -v 'grep' | wc -l) = 1
  test $(ps ax | grep "${no_expected_postgres}" | grep -v 'grep' | wc -l) = 0
  
  output=$(curl http://localhost:5000)
  expected="Hello from your rack app! Aren't kids fun."
  test "${output}" = "${expected}"
}

# puma_migrations_postgres.yml
it_pg_and_puma_running() {

  output=$(curl http://localhost:5000)
  expected="<title>Getting Things Done with Engine Yard AppCloud</title>"
  # [[ ${output} =~ ${expected} ]]
  
  # test_uri_response 'http://localhost:5000' 200
  curl -s -i http://localhost:5000 | grep 'HTTP/1.1 200 OK' | wc -l
}

