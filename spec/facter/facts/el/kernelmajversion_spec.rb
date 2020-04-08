# frozen_string_literal: true

describe Facts::El::Kernelmajversion do
  subject(:fact) { Facts::El::Kernelmajversion.new }

  let(:value) { '4.15' }

  before do
    allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
  end

  it 'calls Facter::Resolvers::Uname' do
    fact.call_the_resolver
    expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
  end

  shared_examples 'kernelmajversion fact expectation' do
    it 'returns the correct kernelmajversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelmajversion', value: value)
    end
  end

  describe '#call_the_resolver' do
    context 'when full version is separated by . delimeter' do
      let(:value) { '4.15' }

      include_examples 'kernelmajversion fact expectation'
    end

    context 'when full version does not have a . delimeter' do
      let(:value) { '4test' }

      include_examples 'kernelmajversion fact expectation'
    end
  end
end
