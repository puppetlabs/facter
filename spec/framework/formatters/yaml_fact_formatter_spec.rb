# frozen_string_literal: true

describe Facter::YamlFactFormatter do
  it 'formats to yaml when no user query' do
    resolved_fact1 =
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin', user_query: '', filter_tokens: [])
    resolved_fact2 =
      double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin', user_query: '', filter_tokens: [])
    resolved_fact3 =
      double(Facter::ResolvedFact, name: 'os.architecture', value: 'x86_64', user_query: '', filter_tokens: [])
    resolved_fact_list = [resolved_fact1, resolved_fact2, resolved_fact3]

    double

    formatted_output = Facter::YamlFactFormatter.new.format(resolved_fact_list)

    expected_output = "os:\n  architecture: x86_64\n  family: Darwin\n  name: Darwin\n"

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to yaml for a single user query' do
    resolved_fact =
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin', user_query: 'os.name', filter_tokens: [])
    resolved_fact_list = [resolved_fact]
    formatted_output = Facter::YamlFactFormatter.new.format(resolved_fact_list)

    expected_output = "os.name: Darwin\n"

    expect(formatted_output).to eq(expected_output)
  end

  it 'formats to yaml for multiple user queries' do
    resolved_fact1 =
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin', user_query: 'os.name', filter_tokens: [])
    resolved_fact2 =
      double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin', user_query: 'os.family', filter_tokens: [])
    resolved_fact_list = [resolved_fact1, resolved_fact2]
    formatted_output = Facter::YamlFactFormatter.new.format(resolved_fact_list)

    expected_output = "os.family: Darwin\nos.name: Darwin\n"

    expect(formatted_output).to eq(expected_output)
  end
end
