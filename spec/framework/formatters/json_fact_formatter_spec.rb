# frozen_string_literal: true

describe Facter::JsonFactFormatter do
  it 'formats to json when no user query' do
    resolved_fact1 =
      instance_double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                            user_query: '', type: :core)
    resolved_fact2 =
      instance_double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin',
                                            user_query: '', type: :core)
    resolved_fact3 =
      instance_double(Facter::ResolvedFact, name: 'os.architecture', value: 'x86_64',
                                            user_query: '', type: :core)
    resolved_fact_list = [resolved_fact1, resolved_fact2, resolved_fact3]

    formatted_output = Facter::JsonFactFormatter.new.format(resolved_fact_list)

    expected_output =
      "{\n  \"os\": {\n    \"architecture\": \"x86_64\",\n    \"family\": \"Darwin\",\n    \"name\": \"Darwin\"\n  }\n}"

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to json for a single user query' do
    resolved_fact =
      instance_double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                            user_query: 'os.name', type: :core)
    resolved_fact_list = [resolved_fact]
    formatted_output = Facter::JsonFactFormatter.new.format(resolved_fact_list)

    expected_output = "{\n  \"os.name\": \"Darwin\"\n}"

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to json for multiple user queries' do
    resolved_fact1 =
      instance_double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                            user_query: 'os.name', type: :core)
    resolved_fact2 =
      instance_double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin',
                                            user_query: 'os.family', type: :core)
    resolved_fact_list = [resolved_fact1, resolved_fact2]
    formatted_output = Facter::JsonFactFormatter.new.format(resolved_fact_list)

    expected_output = "{\n  \"os.family\": \"Darwin\",\n  \"os.name\": \"Darwin\"\n}"

    expect(formatted_output).to eq(expected_output)
  end
end
