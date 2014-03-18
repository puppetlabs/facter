require 'json'
require 'json-schema'

test_name "Running facter --json should validate against the schema"

agents.each do |agent|
  step "Agent #{agent}: run 'facter --json' and validate"
  on(agent, facter('--json')) do
    schema = JSON.parse(File.read("../schema/facter.json"))
    fail_test "facter --json was invalid" unless JSON::Validator.validate!(schema, stdout)
  end
end
