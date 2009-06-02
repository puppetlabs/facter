# Rakefile for facter

$: << File.expand_path('lib')

require './lib/facter.rb'
require 'rake'
require 'rake/packagetask'
require 'rake/gempackagetask'

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
    spec.author = 'Reductive Labs'
    spec.email = 'puppet@reductivelabs.com'
    spec.homepage = 'http://reductivelabs.com'
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

desc "Run the specs under spec/"
task :spec do
    require 'spec'
    require 'spec/rake/spectask'
    # require 'rcov'
    Spec::Rake::SpecTask.new do |t| 
        t.spec_opts = ['--format','s', '--loadby','mtime'] 
        t.spec_files = FileList['spec/**/*.rb']
    end 
end

desc "Prep CI RSpec tests"
task :ci_prep do
    require 'rubygems'
    begin
        gem 'ci_reporter'
        require 'ci/reporter/rake/rspec'
        require 'ci/reporter/rake/test_unit'
        ENV['CI_REPORTS'] = 'results'
    rescue LoadError 
       puts 'Missing ci_reporter gem. You must have the ci_reporter gem installed to run the CI spec tests'
    end
end

desc "Run the CI RSpec tests"
task :ci_spec => [:ci_prep, 'ci:setup:rpsec', :spec]

desc "Send patch information to the puppet-dev list"
task :mail_patches do
    if Dir.glob("00*.patch").length > 0
        raise "Patches already exist matching '00*.patch'; clean up first"
    end

    unless %x{git status} =~ /On branch (.+)/
        raise "Could not get branch from 'git status'"
    end
    branch = $1

    unless branch =~ %r{^([^\/]+)/([^\/]+)/([^\/]+)$}
        raise "Branch name does not follow <type>/<parent>/<name> model; cannot autodetect parent branch"
    end

    type, parent, name = $1, $2, $3

    # Create all of the patches
    sh "git format-patch -C -M -s -n --subject-prefix='PATCH/facter' #{parent}..HEAD"

    # And then mail them out.

    # If we've got more than one patch, add --compose
    if Dir.glob("00*.patch").length > 1
        compose = "--compose"
    else
        compose = ""
    end

    # Now send the mail.
    sh "git send-email #{compose} --no-signed-off-by-cc --suppress-from --to puppet-dev@googlegroups.com 00*.patch"

    # Finally, clean up the patches
    sh "rm 00*.patch"
end
