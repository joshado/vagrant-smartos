Vagrant.require_plugin "vagrant-smartos"

Vagrant.configure("2") do |config|
  config.vm.box = "smartos-dummy"

  config.vm.provider :smartos do |smartos, override|

    smartos.hypervisor = "root@172.16.251.129"
    smartos.image_uuid = "cf7e2f40-9276-11e2-af9a-0bad2233fb0b"

  end
end