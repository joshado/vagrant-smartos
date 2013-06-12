require 'uuid'
require "log4r"
require 'vagrant/util/retryable'

module VagrantPlugins
  module Smartos
    class Provider
      # This runs the configured instance.
      class ReloadInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_smartos::action::reload_instance")
        end

        def call(env)
          vm_uuid = env[:machine].id

          if env[:machine].state.id != :not_created
            env[:ui].info(I18n.t("vagrant_smartos.reloading"))
            output = env[:hyp].exec("vmadm reboot #{vm_uuid}")
            puts "#{output.command}:\n\tstderr=#{output.stderr}\n\tstdout=#{output.stdout}"

            env[:machine].id = nil
          end
        end
      end
    end
  end
end
