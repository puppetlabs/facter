# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "facter"
  s.version = "1.6.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Puppet Labs"]
  s.add_dependency('trollop', '>= 2.0.0')
  s.date = "2012-08-08"
  s.description = "You can prove anything with facts!"
  s.email = "info@puppetlabs.com"
  s.executables = ["facter"]
  s.files = ["bin/facter"]
  s.homepage = "http://puppetlabs.com"
  s.rdoc_options = ["--title", "Facter - System Inventory Tool", "--main", "README", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "facter"
  s.rubygems_version = "1.8.24"
  s.summary = "Facter, a system inventory tool"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
