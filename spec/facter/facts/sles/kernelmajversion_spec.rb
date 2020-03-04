# frozen_string_literal: true

describe Facts::Sles::Kernelmajversion do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajversion', value: '3.12')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return('3.12.49-11-default')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelmajversion', '3.12').and_return(expected_fact)

      fact = Facts::Sles::Kernelmajversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
