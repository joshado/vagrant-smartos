require "vagrant"

module VagrantPlugins
  module Smartos
    module Errors
      class VagrantSmartosError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_smartos.errors")
      end

      class VmadmError < VagrantSmartosError
        error_key(:vmadm)
      end

    end
  end
end