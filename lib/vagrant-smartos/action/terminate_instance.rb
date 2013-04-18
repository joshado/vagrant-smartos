require 'uuid'
require "log4r"
require 'vagrant/util/retryable'

module VagrantPlugins
  module Smartos
    class Provider
      # This runs the configured instance.
      class TerminateInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_smartos::action::terminate_instance")
        end

        def call(env)
          vm_uuid = env[:machine].id

          if env[:machine].state.id != :not_created
            env[:ui].info(I18n.t("vagrant_smartos.terminating"))
            env[:hyp].exec("vmadm destroy #{vm_uuid}")
            env[:machine].id = nil
          end
        end
      end
    end
  end
end
