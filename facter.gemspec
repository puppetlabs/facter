Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.name = 'facter'
  spec.files = `git ls-files`.split($\)
  spec.executables = %w{facter}
  spec.version = `git describe`.strip.split('-')[0]
  spec.summary = 'Facter, a system inventory tool'
  spec.description = 'You can prove anything with facts!'
  spec.author = 'Puppet Labs'
  spec.email = 'info@puppetlabs.com'
  spec.homepage = 'http://puppetlabs.com'
  spec.rubyforge_project = 'facter'
  spec.has_rdoc = true
  spec.rdoc_options <<
    '--title' <<  'Facter - System Inventory Tool' <<
    '--main' << 'README' <<
    '--line-numbers'
end
