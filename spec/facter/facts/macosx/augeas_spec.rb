# frozen_string_literal: true

describe Facts::Macosx::Augeas do
  describe '#call_the_resolver' do
    it 'returns augeas fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'augeas.version', value: '1.12.0')
      allow(Facter::Resolvers::Augeas).to receive(:resolve).with(:augeas_version).and_return('1.12.0')
      allow(Facter::ResolvedFact).to receive(:new).with('augeas.version', '1.12.0').and_return(expected_fact)

      fact = Facts::Macosx::Augeas.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
