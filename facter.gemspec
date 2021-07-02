# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'facter'
  spec.version       = '4.2.2'
  spec.authors       = ['Puppet']
  spec.email         = ['team-nw@puppet.com']
  spec.homepage      = 'https://github.com/puppetlabs/facter'

  spec.summary       = 'Facter, a system inventory tool'
  spec.description   = 'You can prove anything with facts!'
  spec.license       = 'MIT'

  dirs =
    Dir[File.join(__dir__, 'bin/facter')] +
    Dir[File.join(__dir__, 'LICENSE')] +
    Dir[File.join(__dir__, 'lib/**/*.rb')] +
    Dir[File.join(__dir__, 'lib/**/*.json')] +
    Dir[File.join(__dir__, 'lib/**/*.conf')] +
    Dir[File.join(__dir__, 'lib/**/*.erb')]
  base = "#{__dir__}#{File::SEPARATOR}"
  spec.files = dirs.map { |path| path.sub(base, '') }

  spec.required_ruby_version = '>= 2.3', '< 4.0'
  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.81.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.38'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'sys-filesystem', '~> 1.3'
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency 'webmock', '~> 3.12'
  spec.add_development_dependency 'yard', '~> 0.9'

  spec.add_runtime_dependency 'hocon', '~> 1.3'
  spec.add_runtime_dependency 'thor', ['>= 1.0.1', '< 2.0']
end
