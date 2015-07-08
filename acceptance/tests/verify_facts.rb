test_name "verify facts match the schema"

require 'yaml'
require 'set'

def find_child(schema, name, found)
  schema.each do |child_name, value|
    pattern_attribute = value['pattern']
    if (pattern_attribute && name =~ /#{pattern_attribute}/) || child_name == name
      found.add(child_name)
      return value
    end
  end
  nil
end

@ip_pattern = /^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
@ip6_pattern = /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/
@mac_pattern = /^(([0-9a-fA-F]){2}\:){5}([0-9a-fA-F]){2}$/

def validate_fact(name, node, fact_value, hidden)
  is_type = case node['type']
            when 'integer'
              fact_value.is_a? Integer
            when 'double'
              # http://www.yaml.org/spec/1.2/spec.html#id2804092 states the form of a double in YAML
              # If a type isn't explicit, it's reasonable to output a single integer value for a double,
              # as in 0 and 1, instead of 0.0 or 1.0.
              # YAML-CPP seems to drop the decimal whenever it feels like it, so just match Int too.
              fact_value.is_a? Float or fact_value.is_a? Integer or fact_value.to_s =~ /^(\.inf|\.nan|-\.inf)$/
            when 'string'
              fact_value.is_a? String
            when 'ip'
              fact_value.is_a? String and fact_value =~ @ip_pattern
            when 'ip6'
              puts fact_value
              fact_value.is_a? String and fact_value =~ @ip6_pattern
            when 'mac'
              fact_value.is_a? String and fact_value =~ @mac_pattern
            when 'boolean'
              fact_value.is_a? TrueClass or fact_value.is_a? FalseClass
            when 'array'
              fact_value.is_a? Array
            when 'map'
              fact_value.is_a? Hash
            else
              fail "unexpected type in schema at #{node}"
            end
  fail "type of #{name} did not match schema, #{fact_value} is not a #{node['type']}" unless is_type

  hidden_attribute = node['hidden'] || false
  fail "hidden fact was displayed by default" if hidden_attribute != hidden

  if fact_value.is_a? Hash
    elements = node['elements']

    # Validate the map's elements 'validate' is unset or true
    validate_attribute = node['validate'] || true
    if validate_attribute
      # Nested facts are never hidden.
      validate_facts(fact_value, elements, false)
    end
  end
end

def validate_facts(facts, schema, hidden)
  found = Set.new
  facts.each do |name, value|
    next if value.nil? or (value.is_a? String and value.empty?)
    puts name

    fact = find_child(schema, name, found)
    fail "Fact #{name} is not in the schema" unless fact
    validate_fact(name, fact, value, hidden)
  end
end

schema = YAML.load(File.read('../lib/schema/facter.yaml'))

# Get all hidden fact names; we don't have a way to match facts by wildcard, so ignore names with substitutions.
hidden = schema.select { |k, v| v['hidden'] && k !~ /<.*>/ }.map { |k, v| k }

agents.each do |agent|
  step "Agent #{agent}: verify facter output against schema"
  facts = {}
  on(agent, facter('--yaml')) do
    # Validate stdout against the schema
    facts = YAML.load(stdout.chomp)
    validate_facts(facts, schema, false)
  end

  hidden_facts = {}
  on(agent, facter('--yaml', '--show-legacy')) do
    # Re-use facts to find just hidden facts
    all_facts = YAML.load(stdout.chomp)
    hidden_facts = all_facts.reject { |k, v| facts.include? k }
    validate_facts(hidden_facts, schema, true)
  end

  # Confirm hidden_facts has all the hidden entries from the schema
  if missing_hidden = hidden.reject { |k, v| hidden_facts.include? k }
    on(agent, facter(*missing_hidden, '--yaml')) do
      resolved_hidden = YAML.load(stdout.chomp)
      resolved_hidden.each do |name, value|
        fail "missing hidden fact #{name} with value #{value} from legacy output" unless value.empty?
      end
    end
  end
end

