# frozen_string_literal: true

desc 'Create a fact list for the specified os'
task :fact_list_generator, [:os_name] do |_, args|
  ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

  require "#{ROOT_DIR}/lib/framework/core/file_loader"
  load_lib_dirs('facts', '**')

  os_hierarchy = Facter::OsHierarchy.new
  hierarchy = os_hierarchy.construct_hierarchy(args[:os_name])

  internal_fact_loader = Facter::InternalFactLoader.new(hierarchy)
  facts = internal_fact_loader.facts

  fact_mapping = []
  facts.each do |loaded_fact|
    fact_hash = {}
    fact_hash[:name] = loaded_fact.name
    fact_hash[:klass] = loaded_fact.klass
    fact_hash[:type] = loaded_fact.type
    fact_mapping << fact_hash
  end

  puts JSON.pretty_generate(fact_mapping)
end
