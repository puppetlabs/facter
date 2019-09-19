# frozen_string_literal: true

describe 'Windows Path' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'path', value: 'value')
      allow(PathResolver).to receive(:resolve).with(:path).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('path', 'value').and_return(expected_fact)

      fact = Facter::Windows::Path.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
