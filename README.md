# rackapp-boshrelease - BOSH Release

This project is a BOSH release for `rackapp-boshrelease`.

## Properties

See example deployment scenarios in `/examples/` folder. Copy the `properties:` sections into your deployment manifest.

## Preparation

```
git submodule update --init
cd src/todo
bundle
bundle package
cd ../rackapp
bundle
bundle package
cd ../..
```

To create a new BOSH release:

```
bosh create release
```

### Dependencies

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
sudo /vagrant/scripts/install_dependencies
sudo su - vcap
cd /vagrant
./scripts/update examples/rackonly.yml
./scripts/tail_logs -f
```

### Deploying new development releases

Whenever you make changes to your BOSH release, including any applications included, then it is a simple process to create a new development release and deploy it into your vagrant VM:

```
[outside vagrant]
bosh create release --force

[inside vagrant as vcap user]
cd /vagrant
./scripts/update examples/rackonly.yml && ./scripts/tail_logs -f
```

All logs will be sent to the terminal so you can watch for any errors as quickly as possible.

### Finalizing a release

If you create a final release `bosh create release --final`, you must immediately create a new development release. Yeah, this is a bug I guess.

```
[outside vagrant]
bosh create release --final
bosh create release

[inside vagrant as vcap user]
/vagrant/scripts/update examples/rackonly.yml
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

## Run job manually

Job failing to start and you don't know why?

```
[inside vagrant as vcap]
/vagrant/scripts/reset_logs
/vagrant/scripts/configure examples/rackonly.yml
/var/vcap/jobs/webapp/bin/webapp_ctl start
/vagrant/scripts/tail_logs
```



## Issues

If you have trouble accessing the ubuntu package servers, try changing `/etc/resolv.conf` to the following [[source](http://suranyami.com/fixing-temporary-failure-resolving-usarchiveu "Fixing &quot; Temporary failure resolving 'us.archive.ubuntu.com'&quot; in Ubuntu, Vagrant - Suranyami")]:

```
sudo su -

mv /etc/resolv.conf > /etc/resolv.conf.bak
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
```