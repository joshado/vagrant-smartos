require "log4r"

module VagrantPlugins
  module Smartos
    class Provider
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_smartos::action::read_state")
        end

        def call(env)         
          # Try reading the VM's "external" state
          vminfo = env[:machine].id && read_state(env[:hyp], env[:machine])

          # If it's got a DHCP, we'll need to wait until it's running, then read out 
          if !vminfo || vminfo['state'] != "running"
            # Don't do anything until we're actually running...
            env[:machine_state_id] = :not_created
          else
            
            # Mark the state of the VM
            env[:machine_state_id] = vminfo["state"].to_sym

            # If the nic is DHCP, then we'll need to grab the internal state :-\
            if vminfo["nics"].first["ip"] == "dhcp"
              vm_sysinfo = read_internal_state(env[:hyp], env[:machine])
              net0_ip = vm_sysinfo["Virtual Network Interfaces"]["net0"]["ip4addr"] rescue nil # I'm so lazy...

              if vm_sysinfo && net0_ip
                env[:machine_ssh_info] = {
                  :host => net0_ip,
                  :port => 22
                }                
              end

            else
              env[:machine_ssh_info] = {
                :host => vminfo["nics"].first["ip"],
                :port => 22
              }
            end
          end

          @app.call(env)
        end

        # Internal: Reads the zone's internal state using a zlogin <uuid> sysinfo call
        #
        # hyp - the hypervisor object
        # machine - the machine object
        #
        # Returns a hash of the sysinfo data: {"Live Image"=>"20130207T202554Z", "System Type"=>"SunOS", "Boot Time"=>"1371045058", "ZFS Quota"=>"5G", "UUID"=>"22fc9a70-b596-0130-6aac-109add5d41b9", "Hostname"=>"22fc9a70-b596-0130-6aac-109add5d41b9", "Setup"=>"false", "CPU Total Cores"=>1, "MiB of Memory"=>"512", "Virtual Network Interfaces"=>{"net0"=>{"MAC Address"=>"92:ed:e4:cd:c2:de", "ip4addr"=>"172.16.251.147", "Link Status"=>"up", "VLAN"=>"0"}}}
        def read_internal_state(hyp, machine)
          output = hyp.exec("zlogin #{machine.id} sysinfo")
          if output.exit_code != 0
            nil
          else
            JSON.load(output.stdout)
          end
        end


        # Internal: Reads the current state of the machine from the hypervisor
        #
        #  hyp     - the hypervisor connection object
        #  machine - the Vagrant machine object
        #
        # Returns a hash of data returned by vmadm, or nil if the VM isn't found
        def read_state(hyp, machine)
          output = hyp.exec("vmadm get #{machine.id}")

          if output.exit_code != 0 || output.stderr.chomp =~ /No such zone configured/ || output.stdout == ""
            nil
          else
            JSON.load(output.stdout)
          end
        end
      end
    end
  end
end
