# frozen_string_literal: true

desc 'Check changes before committing'
task(:check) do
  puts
  puts '<------------- Running unit tests ------------->'
  Rake::Task['spec_random'].invoke

  puts
  puts '<------------- Running integration tests ------------->'
  Rake::Task['spec_integration'].invoke

  puts
  puts '<------------- Running rubocop ------------->'
  Rake::Task['rubocop'].invoke
end
