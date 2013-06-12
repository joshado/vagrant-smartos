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

          nic = {
            "nic_tag" => env[:machine].provider_config.nic_tag,
            "ip" => env[:machine].provider_config.ip_address,
            "netmask" =>env[:machine].provider_config.subnet_mask,
            "gateway" => env[:machine].provider_config.gateway,
            "primary" => true
          }

          # Make sure we don't pass empty-string gateway / netmask to vmadm, as it isn't happy with this
          nic.delete("netmask") if nic['netmask'].nil? || nic['netmask'].length == 0
          nic.delete("gateway") if nic['gateway'].nil? || nic['gateway'].length == 0


          if env[:machine].provider_config.vlan
            nic["vlan_id"] = env[:machine].provider_config.vlan
          end

          env[:machine].id = UUID.generate

          machine_json = {
            "uuid" => env[:machine].id,
            "brand" => "joyent",
            "image_uuid" => env[:machine].provider_config.image_uuid,
            "alias" => "vagrant-#{Time.now.to_i}",
            "max_physical_memory" => env[:machine].provider_config.ram,
            "quota" => env[:machine].provider_config.quota,
            "nics" => [nic],
            "customer_metadata" => {
              "user-script" => "useradd -s /usr/bin/bash -m vagrant && passwd -N vagrant && mkdir -p ~vagrant/.ssh && echo 'vagrant ALL=NOPASSWD: ALL' >> /opt/local/etc/sudoers && echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' >> ~vagrant/.ssh/authorized_keys"
            }
          }

          # Launch!
          env[:ui].info(I18n.t("vagrant_smartos.launching_instance"))

          output = env[:hyp].exec("vmadm create <<JSON\n#{JSON.dump(machine_json)}\nJSON")
          if output.exit_code != 0 || output.stderr.chomp != "Successfully created #{env[:machine].id}"
            raise Errors::VmadmError, :message => I18n.t("vagrant_smartos.errors.vmadm_create", :output => output.stderr.chomp)
          end

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
