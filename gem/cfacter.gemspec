Gem::Specification.new do |s|
  s.name        = 'cfacter'
  s.version     = '0.0.1'
  s.summary     = "cfacter"
  s.description = "A lightweight facter replacement"
  s.authors     = ["Kylo Ginsberg"]
  s.email       = 'kylo@kylo.net'
  s.files       = ["lib/cfacter.rb"]
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.1'
  s.add_runtime_dependency 'ffi', '1.9.0'
end
