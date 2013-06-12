# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-smartos/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-smartos"
  gem.version       = Vagrant::Smartos::VERSION
  gem.authors       = ["Thomas Haggett"]
  gem.email         = ["thomas@haggett.org"]
  gem.description   = %q{SmartOS Hypervisor provider for Vagrant}
  gem.summary       = %q{SmartOS Hypervisor provider for Vagrant}
  gem.homepage      = "http://github.com/joshado/vagrant-smartos/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "uuid"
end
