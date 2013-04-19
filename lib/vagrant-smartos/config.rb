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

      attr_accessor :nic_tag, :ip_address, :subnet_mask, :gateway, :vlan, :ram, :quota

      def initialize
        @hypervisor = UNSET_VALUE
        @image_uuid = UNSET_VALUE
        @nic_tag = UNSET_VALUE
        @ip_address = UNSET_VALUE
        @subnet_mask = UNSET_VALUE
        @gateway = UNSET_VALUE
        @vlan = UNSET_VALUE
        @ram = UNSET_VALUE
        @quota = UNSET_VALUE
        @__finalized = false
      end

      def finalize!
        @hypervisor = nil if @hypervisor == UNSET_VALUE
        @image_uuid = nil if @image_uuid == UNSET_VALUE
        @nic_tag = "admin" if @nic_tag == UNSET_VALUE
        @ip_address = nil if @ip_address == UNSET_VALUE
        @subnet_mask = nil if @subnet_mask == UNSET_VALUE
        @gateway = nil if @gateway == UNSET_VALUE
        @vlan = nil if @vlan == UNSET_VALUE
        @ram = 256 if @ram == UNSET_VALUE
        @quota = 5 if @quota == UNSET_VALUE

        # Mark that we finalized
        @__finalized = true
      end

      def validate(machine)
        errors = []

        errors << I18n.t("vagrant_smartos.config.hypervisor_required") if @hypervisor.nil?
        errors << I18n.t("vagrant_smartos.config.image_uuid_required") if @image_uuid.nil?
        errors << I18n.t("vagrant_smartos.config.ip_address_required") if @ip_address.nil?
        errors << I18n.t("vagrant_smartos.config.subnet_mask_required") if @subnet_mask.nil?
        errors << I18n.t("vagrant_smartos.config.gateway_required") if @gateway.nil?

        { "SmartOS Provider" => errors }
      end

    end
  end
end
