# rackapp-boshrelease - BOSH Release

This project is a BOSH release for `rackapp-boshrelease`.

## Dependencies

The bosh installation needs the following patches:

* Only set $chroot if not already set - http://reviews.cloudfoundry.org/#/c/7126/

```
cd $BOSH_SRC
git pull ssh://drnic@reviews.cloudfoundry.org:29418/bosh refs/changes/26/7126/1
```

Desirable patches

* Do not fail if the target file of a symlink isn't there - http://reviews.cloudfoundry.org/#/c/7119/

```
cd $BOSH_SRC
git pull ssh://drnic@reviews.cloudfoundry.org:29418/bosh refs/changes/19/7119/1
```


## Development with Vagrant

This project includes development support within Vagrant

```
$ vagrant up
Vendoring bosh source at vendor/bosh (alternately use $BOSH_SRC for other local location)...
remote: Counting objects: 24859, done.
remote: Compressing objects: 100% (8208/8208), done.
...

[default] Attempting graceful shutdown of VM...
[default] Clearing any previously set forwarded ports...
[default] Forwarding ports...
[default] -- 22 => 2222 (adapter 1)
[default] Creating shared folders metadata...
[default] Clearing any previously set network interfaces...
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
cd /vagrant
sudo ./scripts/install_dependencies
./scripts/install
./scripts/configure
./scripts/start
```

Whenever you make changes to your release, you run the following commands in your host machine/laptop and guest VM/vagrant respectively:

```
[inside host]
bosh create release --force

[inside vagrant]
sudo su - vcap
cd /vagrant
./scripts/install
./scripts/configure
./scripts/start
```
