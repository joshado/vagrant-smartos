module VagrantPlugins
  module Smartos
    class Provider
      class MessageAlreadyCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_smartos.already_created"))
          @app.call(env)
        end
      end
    end
  end
end
