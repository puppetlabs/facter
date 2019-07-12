# # -*- encoding: utf-8 -*-
# frozen_string_literal: true
begin
  require 'facter/version'
rescue LoadError
  $LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
  require 'facter/version'
end

  Gem::Specification.new do |s|
    s.name = "facter"
    version = Facter.version
    mdata = version.match(/(\d+\.\d+\.\d+)/)
    s.version = mdata ? mdata[1] : version

    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.authors = ["Puppet Labs"]
    s.date = "2012-08-08"
    s.description = "You can prove anything with facts!"
    s.email = "info@puppetlabs.com"
    s.executables = ["facter"]
    s.files = ["bin/facter"]
    s.homepage = "http://puppetlabs.com"
    s.rdoc_options = ["--title", "Facter - System Inventory Tool", "--main", "README", "--line-numbers"]
    s.require_paths = ["lib"]
    s.rubyforge_project = "facter"
    s.summary = "Facter, a system inventory tool"


    s.add_dependency 'watchr'
    s.add_dependency  'yard'
    s.add_dependency  'redcarpet', '<= 2.3.0'
    

    if Gem.win_platform?
      # FFI dropped 1.9.3 support in 1.9.16, and 1.9.15 was an incomplete release.
      # 1.9.18 is required to support Ruby 2.4
      if RUBY_VERSION.to_f < 2.0
        s.add_dependency 'ffi', '<= 1.9.14'
      elsif RUBY_VERSION.to_f < 2.6
        s.add_dependency 'ffi', '~> 1.9.18'
      else
        s.add_dependency 'ffi', '~> 1.10'
      end
    end
  end
