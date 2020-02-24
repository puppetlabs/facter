# frozen_string_literal: true

describe Facter::Aix::Kernelversion do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: '6100')
      allow(Facter::Resolvers::OsLevel).to receive(:resolve).with(:build).and_return('6100-09-00-0000')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', '6100').and_return(expected_fact)

      fact = Facter::Aix::Kernelversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
