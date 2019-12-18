# frozen_string_literal: true

describe 'LegacyFactFormatter' do
  context 'formats to legacy when no user query' do
    let(:resolved_fact1) do
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin', user_query: '', filter_tokens: [])
    end
    let(:resolved_fact2) do
      double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin', user_query: '', filter_tokens: [])
    end
    let(:resolved_fact3) do
      double(Facter::ResolvedFact, name: 'os.architecture', value: 'x86_64', user_query: '', filter_tokens: [])
    end
    let(:expected_output) { "os => {\n  architecture => \"x86_64\",\n  family => \"Darwin\",\n  name => \"Darwin\"\n}" }
    it 'returns output' do
      formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact1, resolved_fact2, resolved_fact3])

      expect(formatted_output).to eq(expected_output)
    end
  end

  context 'formats to legacy for a single user query' do
    let(:resolved_fact) do
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin', user_query: 'os.name', filter_tokens: [])
    end
    it 'returns single value' do
      formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact])

      expect(formatted_output).to eq('Darwin')
    end
  end

  context 'formats to legacy for a single user query that contains :' do
    let(:resolved_fact) do
      double(Facter::ResolvedFact, name: 'networking.ip6', value: 'fe80::7ca0:ab22:703a:b329',
                                   user_query: 'networking.ip6', filter_tokens: [])
    end
    it 'returns single value without replacing : with =>' do
      formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact])

      expect(formatted_output).to eq('fe80::7ca0:ab22:703a:b329')
    end
  end

  context 'formats to legacy for multiple user queries' do
    let(:resolved_fact1) do
      double(Facter::ResolvedFact, name: 'os.name', value: 'Darwin', user_query: 'os.name', filter_tokens: [])
    end
    let(:resolved_fact2) do
      double(Facter::ResolvedFact, name: 'os.family', value: 'Darwin', user_query: 'os.family', filter_tokens: [])
    end
    let(:expected_output) { "os.family => Darwin\nos.name => Darwin" }
    it 'returns output' do
      formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact1, resolved_fact2])

      expect(formatted_output).to eq(expected_output)
    end
  end

  context 'formats to legacy for empty resolved fact array' do
    it 'returns nil' do
      formatted_output = Facter::LegacyFactFormatter.new.format([])

      expect(formatted_output).to eq(nil)
    end
  end

  context 'when the fact value is nil' do
    let(:resolved_fact) do
      double(Facter::ResolvedFact, name: 'my_external_fact',
                                   value: nil, user_query: 'my_external_fact', filter_tokens: [])
    end
    it 'returns empty string' do
      formatted_output = Facter::LegacyFactFormatter.new.format([resolved_fact])
      expect(formatted_output).to eq('')
    end
  end
end
