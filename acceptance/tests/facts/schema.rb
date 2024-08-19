test_name "Validate facter output conforms to schema" do
  tag 'risk:high'
  confine :except, :platform => 'windows' # See FACT-3479, once resolved this line can be removed
  confine :except, :platform => 'aix-7.3' # FACT-3481 for fixing these
  confine :except, :platform => 'ubuntu-22.04' # FACT-3481
  confine :except, :platform => 'fedora-36' # FACT-3481
  confine :except, :platform => 'el-8-ppc64le' # FACT-3481

  require 'yaml'
  require 'ipaddr'

  # Validates passed in output facts correctly conform to the facter schema, facter.yaml.
  # @param schema_fact The schema fact that matches/corresponds with output_fact
  # @param schema_fact_value The fact value for the schema fact
  # @param output_fact The fact that is being validated
  # @param output_fact The fact value of the output_fact
  def validate_fact(schema_fact, schema_fact_value, output_fact, output_fact_value)
    schema_fact_type = schema_fact ? schema_fact_value["type"] : nil
    fail_test("Fact: #{output_fact} does not exist in schema") unless schema_fact_type

    # For each fact, it is validated by verifying that output_fact_value can
    # successfully parse to fact_type and the output fact has a matching schema
    # fact where both their types and name or regex match.
    case output_fact_value
    when Hash
      fact_type = "map"
    when Array
      fact_type = "array"
    when TrueClass, FalseClass
      fact_type = "boolean"
    when Float
      fact_type = "double"
    when Integer
      fact_type = "integer"
    when String
      if schema_fact_type == "ip"
        begin
          IPAddr.new(output_fact_value).ipv4?
        rescue IPAddr::Error
          fail_test("Invalid ipv4 value given for #{output_fact} with value #{output_fact_value}")
        else
          fact_type = "ip"
        end
      elsif schema_fact_type == "ip6"
        begin
           IPAddr.new(output_fact_value).ipv6?
        rescue IPAddr::Error
          fail_test("Invalid ipv6 value given for #{output_fact} with value #{output_fact_value}")
        else
          fact_type = "ip6"
        end
      elsif schema_fact_type == "mac"
        mac_regex = Regexp.new('^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
        fail_test("Invalid mac value given for #{output_fact} with value #{output_fact_value}") unless mac_regex.match?(output_fact_value)
        fact_type = "mac"
      else
        fact_type = "string"
      end
    else
      fail_test("Invalid fact type given: #{output_fact}")
    end

    # Recurse over facts that have more nested facts within it
    if fact_type == "map"
      if output_fact_value.is_a?(Hash)
        schema_elements = schema_fact_value["elements"]
        output_fact_value.each do |fact, value|
          if value.nil? || !schema_elements
            next
            # Sometimes facts with map as their type aren't nested facts, like
            # hypervisors and simply just a fact with a hash value. For these
            # cases, they don't need to be iterated over.
          end
          schema_fact, schema_fact_value = get_fact(schema_elements, fact)
          validate_fact(schema_fact, schema_fact_value, fact, value)
        end
      end
    end
    assert_match(fact_type, schema_fact_type, "#{output_fact} has value: #{output_fact_value} and type: #{fact_type} does not conform to schema fact value type: #{schema_fact_type}")
  end

  # @param fact_hash The hash being searched for the passed in fact_name
  # @param fact_name The fact that is being searched for
  # @return The fact that has the same name as fact_name, if found. If not found, nil is returned.
  def get_fact(fact_hash, fact_name)
    fact_hash.each_key do |fact|

      # Some facts, like disks.<devicename>, will have different names depending
      # on the machine its running on. For these facts, a pattern AKA a regex is
      # provided in the facter schema. 
      fact_pattern = fact_hash[fact]["pattern"]
      fact_regex = fact_pattern ? Regexp.new(fact_pattern) : nil
      if (fact_pattern && fact_regex.match?(fact_name)) || fact_name == fact
        return fact, fact_hash[fact]
      end
    end
    return nil
  end

  step 'Validate fact collection conforms to schema' do
    agents.each do |agent|

      # Load schema to compare to output_facts
      schema_file = File.join(File.dirname(__FILE__), '../../../lib/schema/facter.yaml')
      schema = YAML.load_file(schema_file)
      on(agent, facter('--yaml --no-custom-facts --no-external-facts')) do |facter_output|

        #get facter output for each platform
        output_facts = YAML.load(facter_output.stdout)

        # validate facter output facts match facter schema
        output_facts.each do |fact, value|
          schema_fact, schema_fact_value = get_fact(schema, fact)
          validate_fact(schema_fact, schema_fact_value, fact, value)
        end
      end
    end
  end
end
