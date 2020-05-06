# frozen_string_literal: true

describe Facts::Linux::Kernelversion do
  subject(:fact) { Facts::Linux::Kernelversion.new }

  let(:resolver_value) { '4.11' }

  before do
    allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(resolver_value)
  end

  it 'calls Facter::Resolvers::Uname' do
    fact.call_the_resolver
    expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
  end

  shared_examples 'kernelversion fact expectation' do
    it 'returns the correct kernelversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelversion', value: fact_value)
    end
  end

  describe '#call_the_resolver' do
    context 'when full version includes ' do
      let(:resolver_value) { '4.11.5-19-generic' }
      let(:fact_value) { '4.11.5' }

      include_examples 'kernelversion fact expectation'
    end

    context 'when full version does not have a . delimeter' do
      let(:resolver_value) { '4test' }
      let(:fact_value) { '4' }

      include_examples 'kernelversion fact expectation'
    end
  end
end
