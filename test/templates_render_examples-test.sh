#!/usr/bin/env roundup

describe "job templates render all examples"

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

[ "$(whoami)" != 'root' ] && ( echo ERROR: run as root user; exit 1 )

cd /vagrant/ # need to hardcode as roundup overrides $0
release_path=$(pwd)
scripts=${release_path}/scripts

examples=$(ls -R ${release_path}/examples/*.yml)

it_configures_successfully_for_each_example() {
  echo "|"
  echo "| Stopping any existing jobs"
  echo "|"
  ${scripts}/stop

  for example in ${examples}
  do
    echo "|"
    echo "| Testing configuration template rendering:"
    echo "| * ${example}"
    echo "|"
    ${scripts}/configure ${example}
  done
  true
}
