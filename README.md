# rackapp-boshrelease - BOSH Release

This project is a BOSH release for `rackapp-boshrelease`.

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
cd /vagrant
./script/install
./script/configure
./script/start
```
