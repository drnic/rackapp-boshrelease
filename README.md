# rackapp-boshrelease - BOSH Release

This project is a BOSH release for `rackapp-boshrelease`.

## Properties

To run migrations

``` yaml
properties:
  webapp:
    run_migrations: 1
```

To run nginx in front of the webapp, and pick one of `http_proxy`, `https_proxy` or `no_proxy` lines.

``` yaml
properties:
  use_nginx: 1
  env:
    # http_proxy: 1
    https_proxy: 1
    # no_proxy: 1
```


## Dependencies

The bosh installation needs the following patches:

* Only set $chroot if not already set - http://reviews.cloudfoundry.org/#/c/7126/

```
cd $BOSH_SRC
git pull ssh://$(whoami)@reviews.cloudfoundry.org:29418/bosh refs/changes/26/7126/1
```

Desirable patches

* Do not fail if the target file of a symlink isn't there - http://reviews.cloudfoundry.org/#/c/7119/

```
cd $BOSH_SRC
git pull ssh://$(whoami)@reviews.cloudfoundry.org:29418/bosh refs/changes/19/7119/1
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
sudo su - vcap
sudo /vagrant/scripts/install_dependencies
sudo su - vcap
cd /vagrant
./scripts/install
./scripts/configure
./scripts/start
```

If you change a **package**, then run the following commands in your host machine/laptop and guest VM/vagrant respectively:

```
[inside host]
bosh create release --force

[inside vagrant as vcap user]
cd /vagrant
./scripts/install
./scripts/configure
./scripts/start
```

If you change a **job**, then run the following commands in your host machine/laptop and guest VM/vagrant respectively:

```
[inside host]
bosh create release --force

[inside vagrant as vcap user]
cd /vagrant
./scripts/configure
./scripts/start
```


## Run job manually

Job failing to start and you don't know why?

```
[inside vagrant as vcap]
/vagrant/scripts/reset_logs
/vagrant/scripts/configure
/var/vcap/jobs/webapp/bin/webapp_ctl start || tail /var/vcap/sys/log/monit/* /var/vcap/sys/log/webapp/*
```

## Issues

If you have trouble accessing the ubuntu package servers, try changing `/etc/resolv.conf` to the following [[source](http://suranyami.com/fixing-temporary-failure-resolving-usarchiveu "Fixing &quot; Temporary failure resolving 'us.archive.ubuntu.com'&quot; in Ubuntu, Vagrant - Suranyami")]:

```
nameserver 8.8.8.8
nameserver 8.8.4.4
```