module VagrantPlugins
  module Smartos
    class Config < Vagrant.plugin("2", :config)
      # The hypervisor to run VMs on
      #
      # @return [String] (username@ipaddress)
      attr_accessor :hypervisor

      # The UUID of the image to use
      #
      # @return [String] UUID
      attr_accessor :image_uuid

      def initialize(region_specific=false)
        @hypervisor = UNSET_VALUE
        @image_uuid = UNSET_VALUE

        # Internal state (prefix with __ so they aren't automatically
        # merged)
        @__compiled_region_configs = {}
        @__finalized = false
        @__region_config = {}
        @__region_specific = region_specific
      end

      def finalize!
        @hypervisor = nil if @hypervisor == UNSET_VALUE
        @image_uuid = nil if @image_uuid == UNSET_VALUE

        # Mark that we finalized
        @__finalized = true
      end

      def validate(machine)
        errors = []

        errors << I18n.t("vagrant_smartos.config.hypervisor_required") if @hypervisor.nil?
        errors << I18n.t("vagrant_smartos.config.image_uuid_required") if @image_uuid.nil?

        { "SmartOS Provider" => errors }
      end

    end
  end
end
