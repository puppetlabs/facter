# frozen_string_literal: true

describe 'Fedora OsFamily' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.family', value: 'RedHat')
      allow(Facter::ResolvedFact).to receive(:new).with('os.family', 'RedHat').and_return(expected_fact)

      fact = Facter::Fedora::OsFamily.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
