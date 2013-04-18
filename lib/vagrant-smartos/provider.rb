require "log4r"
require "vagrant"
require 'vagrant/action/builder'

module VagrantPlugins
  module Smartos
    class Provider < Vagrant.plugin("2", :provider)

      include Vagrant::Action::Builtin

      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :ConnectHypervisor,      action_root.join("connect_hypervisor")
      autoload :IsCreated,              action_root.join("is_created")
      autoload :MessageAlreadyCreated,  action_root.join("message_already_created")
      autoload :MessageNotCreated,      action_root.join("message_not_created")
      autoload :ReadState,              action_root.join("read_state")
      autoload :RunInstance,            action_root.join("run_instance")
      # autoload :SyncFolders, action_root.join("sync_folders")
      # autoload :TimedProvision, action_root.join("timed_provision")
      # autoload :WarnNetworks, action_root.join("warn_networks")
      autoload :TerminateInstance, action_root.join("terminate_instance")

      def initialize(machine)
        @machine = machine
      end

      def action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHypervisor
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyCreated
              next
            end

#            b2.use SyncFolders
            b2.use RunInstance


          end
        end
      end

      def action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHypervisor
          b.use TerminateInstance
        end

      end

      def action_provision

      end

      def action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHypervisor
          b.use ReadSSHInfo
        end
      end

      def action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHypervisor
          b.use ReadState
        end
      end

      def action_ssh

      end

      def action_ssh_run

      end

      def action(name)
        case name.intern
        when :up
          action_up
        when :read_state
          action_read_state
        when :destroy
          action_destroy
        end
      end

      def ssh_info
        # Run a custom action called "read_ssh_info" which does what it
        # says and puts the resulting SSH info into the `:machine_ssh_info`
        # key in the environment.
        env = @machine.action("read_state")

        env[:machine_ssh_info]
      end

      def state
        # Run a custom action we define called "read_state" which does
        # what it says. It puts the state in the `:machine_state_id`
        # key in the environment.
        env = @machine.action("read_state")

        state_id = env[:machine_state_id]

        # Get the short and long description
        short = I18n.t("vagrant_smartos.states.short_#{state_id}")
        long  = I18n.t("vagrant_smartos.states.long_#{state_id}")

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? "new" : @machine.id
        "SmartOS (#{id})"
      end
    end
  end
end
