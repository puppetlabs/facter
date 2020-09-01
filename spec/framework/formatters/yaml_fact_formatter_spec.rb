# frozen_string_literal: true

describe Facter::YamlFactFormatter do
  subject(:yaml_formatter) { Facter::YamlFactFormatter.new }

  let(:resolved_fact1) do
    instance_spy(Facter::ResolvedFact, name: 'os.name', value: 'Darwin',
                                       user_query: user_query1, filter_tokens: [], type: :core)
  end
  let(:resolved_fact2) do
    instance_spy(Facter::ResolvedFact, name: 'os.family', value: 'Darwin',
                                       user_query: user_query2, filter_tokens: [], type: :core)
  end
  let(:resolved_fact3) do
    instance_spy(Facter::ResolvedFact, name: 'os.architecture', value: 'x86_64',
                                       user_query: user_query3, filter_tokens: [], type: :core)
  end

  let(:float_fact) do
    instance_spy(Facter::ResolvedFact, name: 'memory', value: 1024.0,
                                       user_query: '', filter_tokens: [], type: :core)
  end

  let(:user_query1) { '' }
  let(:user_query2) { '' }
  let(:user_query3) { '' }

  context 'when no user query' do
    let(:resolved_fact_list) { [resolved_fact1, resolved_fact2, resolved_fact3] }
    let(:expected_output) { "os:\n  architecture: x86_64\n  family: \"Darwin\"\n  name: \"Darwin\"\n" }

    it 'formats to yaml' do
      expect(yaml_formatter.format(resolved_fact_list)).to eq(expected_output)
    end
  end

  context 'when there is a single user query' do
    let(:resolved_fact_list) { [resolved_fact1] }
    let(:expected_output) { "os.name: \"Darwin\"\n" }
    let(:user_query1) { 'os.name' }

    it 'formats to yaml' do
      expect(yaml_formatter.format(resolved_fact_list)).to eq(expected_output)
    end
  end

  context 'when there are multiple user queries' do
    let(:resolved_fact_list) { [resolved_fact1, resolved_fact2] }
    let(:expected_output) { "os.family: \"Darwin\"\nos.name: \"Darwin\"\n" }
    let(:user_query1) { 'os.name' }
    let(:user_query2) { 'os.family' }

    it 'formats to yaml' do
      expect(yaml_formatter.format(resolved_fact_list)).to eq(expected_output)
    end
  end

  context 'when on Windows' do
    let(:win_path) do
      instance_spy(Facter::ResolvedFact, name: 'path', value: value,
                                         user_query: '', filter_tokens: [], type: :core)
    end
    let(:value) { 'C:\\Program Files\\Puppet Labs\\Puppet\\bin;C:\\cygwin64\\bin' }
    let(:expected_output) { "path: \"C:\\\\Program Files\\\\Puppet Labs\\\\Puppet\\\\bin;C:\\\\cygwin64\\\\bin\"\n" }
    let(:resolved_fact_list) { [win_path] }

    it 'formats quoted path with double escaped backslashes' do
      expect(yaml_formatter.format(resolved_fact_list)).to eq(expected_output)
    end
  end

  context 'when resolving float numbers' do
    let(:resolved_fact_list) { [float_fact] }
    let(:expected_output) { "memory: 1024.0\n" }

    it 'does not use quotes' do
      expect(yaml_formatter.format(resolved_fact_list)).to eq(expected_output)
    end
  end
end
