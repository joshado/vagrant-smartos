require 'net/ssh'

module VagrantPlugins

  module Smartos
    class Provider


      class SshWrapper
        def initialize(net_ssh)
          @ssh = net_ssh
        end
        
        UnexpectedExitCode = Class.new(RuntimeError)
        CommandExecutionFailed = Class.new(RuntimeError)

        # Public: Execute and block on a command on the remote SSH server
        #
        # Returns the stdout data, stderr is piped out to screen
        #
        # Raises SshWrapper::UnexpectedExitCode if the exitcode is non-0
        # Raises SshWrapper::CommandExecutionFailed if the command failed to execute
        def exec(command)
          stdout_data = []
          channel = @ssh.open_channel do |ch|
            ch.exec command do |ch, success|
              raise SshWrapper::CommandExecutionFailed unless success

              # "on_data" is called when the process writes something to stdout
              ch.on_data do |c, data|
                stdout_data << data
              end

              # "on_extended_data" is called when the process writes something to stderr
              ch.on_extended_data do |c, type, data|
                $stderr.print data
              end

              channel.on_request("exit-status") do |ch,data|
                raise SshWrapper::UnexpectedExitCode unless data.read_long == 0
              end
            end
          end

          channel.wait

          stdout_data.join("")
        end
      end


      class ConnectHypervisor

        def initialize(app, env)
          @app    = app 
          @logger = Log4r::Logger.new("vagrant_smartos::action::connect_hypervisor")
        end

        def call(env)

          username,hostname = env[:machine].provider_config.hypervisor.split("@")

          Net::SSH.start(hostname,username) do |ssh|

            env[:hyp_ssh] = ssh
            env[:hyp] = SshWrapper.new(ssh)
            @app.call(env)

          end

        end

      end

    end
  end
end
