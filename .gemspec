# -*- encoding: utf-8 -*-
#
# PLEASE NOTE
# This gemspec is not intended to be used for building the Facter gem.  This
# gemspec is intended for use with bundler when Facter is a dependency of
# another project.  For example, the stdlib project is able to integrate with
# the master branch of Facter by using a Gemfile path of
# git://github.com/puppetlabs/facter.git
#
# Please see the [packaging
# repository](https://github.com/puppetlabs/packaging) for information on how
# to build the Puppet gem package.

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

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
