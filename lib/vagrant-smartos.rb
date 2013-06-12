require 'pathname'

require "vagrant-smartos/version"
require 'vagrant-smartos/plugin'
require 'vagrant-smartos/errors'

module VagrantPlugins
  module Smartos
    lib_path = Pathname.new(File.expand_path("../vagrant-smartos", __FILE__))


    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end

  end
end
