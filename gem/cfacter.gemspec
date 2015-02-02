Gem::Specification.new do |s|
  s.name        = 'cfacter'
  s.version     = '0.3.0'
  s.summary     = 'cfacter'
  s.description = 'A lightweight facter replacement'
  s.authors     = ["Puppet Labs"]
  s.email       = 'cfacter@puppetlabs.com'
  s.homepage    = "http://puppetlabs.com"
  s.license     = 'Apache-2.0'
  s.files       = ['lib/cfacter.rb']
  s.add_runtime_dependency 'ffi', '~> 1.9', '>= 1.9.6'
end
