# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'open3'
require 'rspec/core/rake_task'
require 'facter/version'

Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

task default: :spec

desc 'Generate changelog'
task :changelog, [:version] do |_t, args|
  sh "./scripts/generate_changelog.rb #{args[:version]}"
end

namespace :pl_ci do
  desc 'build the gem and place it at the directory root'
  task :gem_build do
    stdout, stderr, status = Open3.capture3('gem build facter.gemspec')
    if !status.exitstatus.zero?
      puts "Error building facter.gemspec \n#{stdout} \n#{stderr}"
      exit(1)
    else
      puts stdout
    end
  end
end

if Rake.application.top_level_tasks.grep(/^(pl:|package:)/).any?
  begin
    require 'packaging'
    Pkg::Util::RakeUtils.load_packaging_tasks
  rescue LoadError => e
    puts "Error loading packaging rake tasks: #{e}"
  end
end
