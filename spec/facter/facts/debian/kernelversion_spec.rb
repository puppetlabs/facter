# frozen_string_literal: true

describe Facter::Debian::Kernelversion do
  shared_examples 'kernelversion fact expectation' do
    it 'returns the correct kernelversion' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(input)
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', value).and_return(expected_fact)

      fact = Facter::Debian::Kernelversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end

  describe '#call_the_resolver' do
    context 'when full version includes ' do
      let(:input) { '4.11.5-19-generic' }
      let(:value) { '4.11.5' }

      include_examples 'kernelversion fact expectation'
    end

    context 'when full version does not have a . delimeter' do
      let(:input) { '4test' }
      let(:value) { '4' }

      include_examples 'kernelversion fact expectation'
    end
  end
end
