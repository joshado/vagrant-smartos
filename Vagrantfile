Vagrant.require_plugin "vagrant-smartos"

Vagrant.configure("2") do |config|
  config.vm.box = "smartos-dummy"

  config.vm.provider :smartos do |smartos, override|

    smartos.hypervisor = "root@172.16.251.129"
    smartos.image_uuid = "cf7e2f40-9276-11e2-af9a-0bad2233fb0b"

    smartos.ip_address = "172.16.251.18"
    smartos.subnet_mask = "255.255.255.0"
    smartos.gateway = "172.16.251.2"


  end

  config.vm.synced_folder "locales/", "/vagrant"
end