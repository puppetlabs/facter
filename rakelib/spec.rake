# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  desc 'Run rspec test in sequential order'
  RSpec::Core::RakeTask.new(:spec)

  desc 'Run rspec test in random order'
  RSpec::Core::RakeTask.new(:spec_random) do |t|
    t.rspec_opts = '--order random'
  end

  desc 'Run rspec integration test in random order'
  RSpec::Core::RakeTask.new(:spec_integration) do |t|
    t.rspec_opts = '--pattern spec_integration/**/*_spec.rb '\
                   '--default-path spec_integration --order random'
  end
rescue LoadError
  puts 'Could not load rspec'
end
