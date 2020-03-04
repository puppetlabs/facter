# frozen_string_literal: true

describe Facts::El::Kernelversion do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '4.19.2'

      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', value).and_return(expected_fact)

      fact = Facts::El::Kernelversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
