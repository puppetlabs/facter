desc '...'
task :create_fact, [:os, :fact_name] do |task, args|
  require_relative 'fact_generator/fact_creator'

  fact_creator = FactCreator.new
  fact_creator.create_fact(args[:os], args[:fact_name])
end

desc '...'
task :create_facts do
  require_relative 'fact_generator/fact_creator'

  fact_creator = FactCreator.new
  fact_creator.create_facts
end
