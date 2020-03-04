# frozen_string_literal: true

describe Facts::Macosx::Kernelrelease do
  describe '#call_the_resolver' do
    let(:value) { '18.7.0' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelrelease', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernelrelease', value).and_return(expected_fact)

      fact = Facts::Macosx::Kernelrelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
