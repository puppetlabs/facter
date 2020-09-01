# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'facter/version'

RSpec::Core::RakeTask.new(:spec)
Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

task default: :spec

desc 'Generate changelog'
task :changelog, [:version] do |_t, args|
  sh "./scripts/generate_changelog.rb #{args[:version]}"
end
