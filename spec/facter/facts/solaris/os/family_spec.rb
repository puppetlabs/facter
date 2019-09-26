# frozen_string_literal: true

describe 'Solaris OsFamily' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.family', value: 'Solaris')
      allow(Facter::ResolvedFact).to receive(:new).with('os.family', 'Solaris').and_return(expected_fact)

      fact = Facter::Solaris::OsFamily.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
