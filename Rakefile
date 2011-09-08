# Rakefile for facter

$: << File.expand_path('lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'
begin
    require 'rcov'
rescue LoadError
end

Dir['tasks/**/*.rake'].each { |t| load t }

require 'rake'
require 'rake/packagetask'
require 'rake/gempackagetask'

module Facter
    FACTERVERSION = File.read('lib/facter.rb')[/FACTERVERSION *= *'(.*)'/,1] or fail "Couldn't find FACTERVERSION"
end

FILES = FileList[
    '[A-Z]*',
    'install.rb',
    'bin/**/*',
    'lib/**/*',
    'conf/**/*',
    'etc/**/*',
    'spec/**/*'
]

spec = Gem::Specification.new do |spec|
    spec.platform = Gem::Platform::RUBY
    spec.name = 'facter'
    spec.files = FILES.to_a
    spec.executables = %w{facter}
    spec.version = Facter::FACTERVERSION
    spec.summary = 'Facter, a system inventory tool'
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

Rake::PackageTask.new("facter", Facter::FACTERVERSION) do |pkg|
    pkg.package_dir = 'pkg'
    pkg.need_tar_gz = true
    pkg.package_files = FILES.to_a
end

Rake::GemPackageTask.new(spec) do |pkg|
end

task :default do
    sh %{rake -T}
end

RSpec::Core::RakeTask.new do |t|
    t.pattern ='spec/{unit,integration}/**/*_spec.rb'
    t.fail_on_error = true
end

RSpec::Core::RakeTask.new('spec:rcov') do |t|
    t.pattern ='spec/{unit,integration}/**/*_spec.rb'
    t.fail_on_error = true
    if defined?(Rcov)
        t.rcov = true
        t.rcov_opts = ['--exclude', 'spec/*,test/*,results/*,/usr/lib/*,/usr/local/lib/*,gems/*']
    end
end
