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
          output = env[:machine].id && read_state(env[:hyp], env[:machine])

          if output
            env[:machine_state_id] = output["state"].to_sym
            env[:machine_ssh_info] = {
              :host => output["nics"].first["ip"],
              :port => 22
            }
          else
            env[:machine_state_id] = :not_created
          end

          @app.call(env)
        end

        def read_state(hyp, machine)
          begin
            output = hyp.exec("vmadm get #{machine.id}")
          rescue SshWrapper::UnexpectedExitCode
            return :not_created
          end

          if output.chomp == ""
            nil
          else
            JSON.load(output)
          end
        end
      end
    end
  end
end
