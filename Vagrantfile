Vagrant.require_plugin "vagrant-smartos"

Vagrant.configure("2") do |config|
  config.vm.box = "smartos-dummy"

  config.vm.provider :smartos do |smartos, override|

    smartos.hypervisor = "root@172.16.251.129"
    smartos.image_uuid = "9eac5c0c-a941-11e2-a7dc-57a6b041988f"

    smartos.ip_address = "172.16.251.18"
    smartos.subnet_mask = "255.255.255.0"
    smartos.gateway = "172.16.251.2"
  end

  config.vm.synced_folder "locales/", "/vagrant"


  config.vm.define :test1 do |test|
    test.vm.provider :smartos do |smartos, override|
      smartos.ip_address = "172.16.251.21"
    end
  end

  config.vm.define :test2 do |test|
    test.vm.provider :smartos do |smartos, override|
      smartos.ip_address = "172.16.251.22"
    end
  end

  config.vm.define :test3 do |test|
    test.vm.provider :smartos do |smartos, override|
      smartos.ip_address = "172.16.251.23"
    end
  end

  config.vm.define :test4 do |test|
    test.vm.provider :smartos do |smartos, override|
      smartos.ip_address = "172.16.251.24"
    end
  end

end
