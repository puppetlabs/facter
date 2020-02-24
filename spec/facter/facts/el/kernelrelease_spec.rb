# frozen_string_literal: true

describe Facter::El::Kernelrelease do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '4.19.2-300.fc29.x86_64'

      expected_fact = double(Facter::ResolvedFact, name: 'kernelrelease', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernelrelease', value).and_return(expected_fact)

      fact = Facter::El::Kernelrelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
