# rackapp-boshrelease - BOSH Release

This project is a BOSH release for `rackapp-boshrelease`.

## Properties

See example deployment scenarios in `/examples/` folder. Copy the `properties:` sections into your deployment manifest.

## Preparation

To fetch submoduled sources, sync large blobs and create the first installable development BOSH release:

```
git submodule update --init
bosh create release
```

### Dependencies

The bosh installation needs the following patches:

* Only set $chroot if not already set - http://reviews.cloudfoundry.org/#/c/7126/

```
cd $BOSH_SRC
git fetch ssh://$(whoami)@reviews.cloudfoundry.org:29418/bosh refs/changes/26/7126/1 && git cherry-pick FETCH_HEAD
```

Desirable patches

* Do not fail if the target file of a symlink isn't there - http://reviews.cloudfoundry.org/#/c/7119/

```
cd $BOSH_SRC
git fetch ssh://$(whoami)@reviews.cloudfoundry.org:29418/bosh refs/changes/19/7119/1 && git cherry-pick FETCH_HEAD
```

## Development with Vagrant

This project includes development support within Vagrant

```
$ vagrant up
Vendoring bosh source at vendor/bosh (alternately use $BOSH_SRC for other local location)...
remote: Counting objects: 24859, done.
remote: Compressing objects: 100% (8208/8208), done.
...
[default] Booting VM...
[default] Waiting for VM to boot. This can take a few minutes.
[default] VM booted and ready for use!
[default] Mounting shared folders...
[default] -- bosh-src: /bosh
[default] -- v-root: /vagrant

$ vagrant ssh
```

Inside the VM:

```
sudo /vagrant/scripts/install_dependencies
sudo su - vcap
cd /vagrant
sudo ./scripts/update examples/puma_migrations_postgres.yml
sudo ./scripts/tail_logs -f
```

### Deploying new development releases

Whenever you make changes to your BOSH release, including any applications included, then it is a simple process to create a new development release and deploy it into your vagrant VM:

```
[outside vagrant]
bosh create release --force

[inside vagrant as vcap user]
cd /vagrant
sudo ./scripts/update examples/puma_migrations_postgres.yml && sudo ./scripts/tail_logs -f
```

All logs will be sent to the terminal so you can watch for any errors as quickly as possible.

### Finalizing a release

If you create a final release `bosh create release --final`, you must immediately create a new development release. Yeah, this is a bug I guess.

```
[outside vagrant]
bosh create release --final
bosh create release

[inside vagrant as vcap user]
/vagrant/scripts/update examples/puma_migrations_postgres.yml
```


### Alternate configurations

This BOSH release is configurable during deployment with properties. 

Please maintain example scenarios in the `examples/` folder.

To switch between example scenarios, run `scripts/update` with a different example scenario.

```
[inside vagrant as vcap user]
/vagrant/scripts/update examples/nginx.yml
```


### Automatically update

NOTE: This is WIP due to this vagrant/listen [issue](https://github.com/guard/listen/issues/53).

If you run `/vagrant/scripts/autoupdate /vagrant/examples/rackonly.yml` within vagrant (as vagrant user), then it [should] automatically stop/install/configure/start the release whenever a new development release is created in the host machine.

## Tests

Tests are a WIP. Here is the current test script and how to run it. If it fails, all the log files will be displayed.

To run all tests:

```
[inside vagrant as root]
cd /vagrant/test
roundup
```

To run & debug a specific test:

```
[inside vagrant as root]
./vagrant/test/wordpress-test.sh || ./scripts/tail_error_logs -n 200
```

The test scripts use [roundup](http://bmizerany.github.com/roundup/ "roundup"), which is installed via `scripts/install_dependencies`.

### Clear out logs

You can reset all logs to empty size

```
./scripts/reset_logs
```

You can also stop all processes and delete all logs.

```
./scripts/stop 
./scripts/helpers/list_logs | xargs rm
```

## Deployment without BOSH

This release can be installed into a single VM without requiring BOSH running.

Within an Ubuntu 64-bit VM, as root user:

```
apt-get install git-core -y
ssh-keygen
# add the ~/.ssh/id_dsa.pub to your github user profile
# add the ~/.ssh/id_dsa.pub to your gerrit user profile

git clone git@github.com:engineyard/rackapp-boshrelease.git
cd rackapp-boshrelease

./scripts/install_ruby
./scripts/fetch_bosh /bosh GERRIT_USER
./scripts/install_dependencies

git submodule update --init
bosh create release
./scripts/update examples/puma_migrations_postgres.yml
```

URLs:

* [github ssh keys](https://github.com/settings/ssh)
* [gerrit ssh keys](http://reviews.cloudfoundry.org/#/settings/ssh-keys "Gerrit Code Review")

## Issues

If you have trouble accessing the ubuntu package servers, try changing `/etc/resolv.conf` to the following [[source](http://suranyami.com/fixing-temporary-failure-resolving-usarchiveu "Fixing &quot; Temporary failure resolving 'us.archive.ubuntu.com'&quot; in Ubuntu, Vagrant - Suranyami")]:

```
sudo su -

mv /etc/resolv.conf /etc/resolv.conf.bak
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
```