# frozen_string_literal: true

describe 'Macosx Kernelversion' do
  context '#call_the_resolver' do
    let(:value) { '18.7.0' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', value).and_return(expected_fact)

      fact = Facter::Macosx::Kernelversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
