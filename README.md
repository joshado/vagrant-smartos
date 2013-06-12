# Vagrant SmartOS Provider

Provision SmartOS zones using vagrant. For now, it only works with OS container zones.

## Notes

This has only been demonstrated to work against a SmartOS hypervisor running in a VMware Fusion image, but since it's only interacted with via SSH, there is no reason why this won't work against a physical SmartOS hypervisor.

This is purely a prototype / proof-of-concept hacked together. I make no apologies for the state of the code or the lack of tests. Feel free to fix and pull-request :-p

Also, right now it uses a dummy box to get vagrant to play ball, whilst requiring an `image_uuid` parameter in the Vagrantfile. It might be much tidier if we could package up SmartOS images into vagrant-boxes and use those.

## Installation

* Get Vagrant 1.2.0+ installed (see elsewhere - I've been building using version 1.2.2).

* Install the gem from RubyGems:

  `vagrant plugin install --plugin-prerelease --plugin-source https://rubygems.org/ vagrant-smartos`

* Add the dummy box:

  `vagrant box add smartos-dummy https://github.com/joshado/vagrant-smartos/raw/master/example_box/smartos.box`

* Boot a SmartOS hypervisor somewhere. It shouldn't matter if this is VMWare Fusion, VirtualBox or a dedicated machine, as long as you have SSH access to it.

* Ensure your local ssh key is in the roots `authorized_keys` file on the SmartOS box. The simple way to test this is to `ssh root@<hypervisor ip>` from your workstation, which should drop you straight into a root shell on the hypervisor.

* Write your `Vagrantfile`. See below for an example one and the options you can provide.

* Run your VMs:

  `vagrant up --provider=smartos`

* Now, try logging in :)

  `vagrant ssh`


## Example Vagrantfile and options

There are two specific parameters required for the SmartOS provider (`hypervisor` and `image_uuid`) and a bunch of optional ones, you should be able to work it out:

    Vagrant.require_plugin "vagrant-smartos"

    Vagrant.configure("2") do |config|

      # For the time being, use our dummy box
      config.vm.box = "smartos-dummy"

      config.vm.provider :smartos do |smartos, override|
        # Required: This is which hypervisor to provision the VM on.
        # The format must be "<username>@<ip or hostname>"
        smartos.hypervisor = "root@172.16.251.129"

        # Required: This is the UUID of the SmartOS image to use for the VMs. 
        # It must already be imported using `imgadm` before running `vagrant up`.
        smartos.image_uuid = "cf7e2f40-9276-11e2-af9a-0bad2233fb0b"  # this is base64:1.9.1

        # Optional: The RAM allocation for the machine, defaults to the SmartOS default (256MB)
        # smartos.ram = 512

        # Optional: Disk quota for the machine, defaults to the SmartOS default (5G)
        # smartos.quota = 10

        # Optional: Specify the nic_tag to use
        # If omitted, 'admin' will be the default
        # smartos.nic_tag = "admin"

        # Optional: Specify a static IP address for the VM
        # If omitted, 'dhcp' will be used
        # smartos.ip_address = "1.2.3.4"

        # Optional: Specify the net-mask (required if not using dhcp)
        # smartos.subnet_mask = "255.255.255.0"

        # Optional: Specify the gateway (required if not using dhcp)
        # smartos.gateway = "255.255.255.0"

        # Optional: Specify a VLAN tag for this VM
        # smartos.vlan = 1234
      end

      # RSync'ed shared folders should work as normal
      config.vm.synced_folder "./", "/work-dir"

      # Multi-VMs should be fine, too; they will take the default parameters from above, and you can override
      # specifics for each VM
      #
      # config.vm.define :box1 do |box|
      #    box.vm.provider :smartos do |smartos, override|
      #      smartos.ip_address = "172.16.251.21"
      #    end
      # end
      #
      # config.vm.define :box2 do |box|
      #    box.vm.provider :smartos do |smartos, override|
      #      smartos.ip_address = "172.16.251.21"
      #    end
      # end
      #

    end



## Problems, fixes?

Open an issue, or even better, a pull request :D
