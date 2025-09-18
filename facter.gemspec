# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'facter'
  spec.version       = '4.11.0'
  spec.authors       = ['Puppet']
  spec.email         = ['team-nw@puppet.com']
  spec.homepage      = 'https://github.com/puppetlabs/facter'

  spec.summary       = 'Facter, a system inventory tool'
  spec.description   = 'You can prove anything with facts!'
  spec.license       = 'Apache-2.0'

  dirs =
    Dir[File.join(__dir__, 'bin/facter')] +
    Dir[File.join(__dir__, 'LICENSE')] +
    Dir[File.join(__dir__, 'lib/**/*.rb')] +
    Dir[File.join(__dir__, 'lib/**/*.json')] +
    Dir[File.join(__dir__, 'lib/**/*.conf')] +
    Dir[File.join(__dir__, 'lib/**/*.erb')]
  base = "#{__dir__}#{File::SEPARATOR}"
  spec.files = dirs.map { |path| path.sub(base, '') }

  spec.required_ruby_version = '>= 2.5', '< 4.0'
  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.28' # last version to support 2.5
  spec.add_development_dependency 'rubocop-performance', '~> 1.5.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.10' # last version to support 2.5
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'webmock', '~> 3.12'
  spec.add_development_dependency 'yard', '~> 0.9'

  # ffi 1.16.0 - 1.16.2 are broken on Windows
  spec.add_runtime_dependency 'ffi', '>= 1.15.5', '< 1.17.0', '!= 1.16.0', '!= 1.16.1', '!= 1.16.2'
  spec.add_runtime_dependency 'hocon', '~> 1.3'
  # Without sys-filesystem the mountpoints fact returns no data and the
  # partitions fact reports incorrect data, as it is missing the mount
  # information for partitions. Though adding sys-filesystem as a runtime
  # dependency requires gem install invocations to have a C compiler available,
  # this requirement is preferred to producing a broken gem. Adding as a
  # runtime dependency also ensures that tools such as gem2deb properly include
  # sys-filesystem as a dependency.
  spec.add_runtime_dependency 'sys-filesystem', '~> 1.4'
  spec.add_runtime_dependency 'thor', ['>= 1.0.1', '< 1.3'] # Thor 1.3.0 drops support for Ruby 2.5
end
