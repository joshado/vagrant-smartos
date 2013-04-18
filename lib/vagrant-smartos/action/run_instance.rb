require 'uuid'
require "log4r"
require 'vagrant/util/retryable'

module VagrantPlugins
  module Smartos
    class Provider

      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_smartos::action::run_instance")
        end

        def call(env)

          image_uuid = env[:machine].provider_config.image_uuid

          vlan = "" #104
          nic_tag = "admin"
          ip_address = "172.16.251.120"
          subnet_mask = "255.255.255.0"
          gateway = "172.16.251.2"

          # Launch!
          env[:ui].info(I18n.t("vagrant_smartos.launching_instance"))
          env[:ui].info(" -- Image UUID: #{image_uuid}")
          env[:ui].info(" -- VLAN: #{vlan} (#{nic_tag})")
          env[:ui].info(" -- IP: #{ip_address}")
          env[:ui].info(" -- Mask: #{subnet_mask}")
          env[:ui].info(" -- Gateway: #{gateway}")

          #### DO THE THING
          # Immediately save the ID since it is created at this point.
          env[:machine].id = UUID.generate

          machine_json = {
            "uuid" => env[:machine].id,
            "brand" => "joyent",
            "image_uuid" => image_uuid,
            "alias" => "vagrant-#{Time.now.to_i}",
            "max_physical_memory" => 256,
            "quota" => 5,
            "nics" => [
              {
                "nic_tag" => nic_tag,
                #{}"vlan_id" => vlan,
                "ip" => ip_address,
                "netmask" => subnet_mask,
                "gateway" => gateway,
                "primary" => true
              }
            ],
            "customer_metadata" => {
              "user-script" => "useradd vagrant && passwd -N vagrant && mkdir -p ~vagrant/.ssh && echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' >> ~vagrant/.ssh/authorized_keys"
            }
          }

          env[:hyp].exec("vmadm create <<JSON\n#{JSON.dump(machine_json)}\nJSON")

          env[:ui].info(I18n.t("vagrant_smartos.waiting_for_ready"))
          while true
            break if env[:interrupted]
            break if env[:machine].provider.state.id == :running
            sleep 2
          end

          env[:ui].info(I18n.t("vagrant_smartos.waiting_for_ssh"))
          while true
            break if env[:interrupted]
            break if env[:machine].communicate.ready?
            sleep 2
          end

          if env[:interrupted]
            terminate(env) 
          else
            env[:ui].info(I18n.t("vagrant_smartos.ready"))
          end

          @app.call(env)
        end

        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if env[:machine].provider.state.id != :not_created
            # Undo the import
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(env[:machine].provider.action_destroy, destroy_env)
        end
      end
    end
  end
end
