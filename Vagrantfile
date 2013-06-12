Vagrant.require_plugin "vagrant-smartos"

Vagrant.configure("2") do |config|
  config.vm.box = "smartos-dummy"

  config.vm.provider :smartos do |smartos, override|

    smartos.hypervisor = "root@172.16.251.129"
    smartos.image_uuid = "13ba5a87-caa8-4092-a488-65589afb7799"
    smartos.ram = 512
    
    # smartos.ip_address = "172.16.251.18"
    # smartos.subnet_mask = "255.255.255.0"
    # smartos.gateway = "172.16.251.2"
  end

  config.vm.synced_folder "locales/", "/vagrant"


  config.vm.define :test1 do |test|
#    test.vm.provider :smartos do |smartos, override|
#      smartos.ip_address = "172.16.251.21"
#    end
  end



end
