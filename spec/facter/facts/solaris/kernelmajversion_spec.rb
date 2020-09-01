# frozen_string_literal: true

describe Facts::Solaris::Kernelmajversion do
  subject(:fact) { Facts::Solaris::Kernelmajversion.new }

  let(:resolver_value) { '4.15' }

  before do
    allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelversion).and_return(resolver_value)
  end

  it 'calls Facter::Resolvers::Uname' do
    fact.call_the_resolver
    expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelversion)
  end

  shared_examples 'kernelmajversion fact expectation' do
    it 'returns the correct kernelmajversion fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'kernelmajversion', value: fact_value)
    end
  end

  describe '#call_the_resolver' do
    context 'when on Solaris 11.4' do
      let(:resolver_value) { '11.4.0.15.0' }
      let(:fact_value) { '11.4' }

      include_examples 'kernelmajversion fact expectation'
    end

    context 'when on Solaris 11.3' do
      let(:resolver_value) { '11.3' }
      let(:fact_value) { '11' }

      include_examples 'kernelmajversion fact expectation'
    end

    context 'when full version does not have a . delimeter' do
      let(:resolver_value) { '4test' }
      let(:fact_value) { '4test' }

      include_examples 'kernelmajversion fact expectation'
    end
  end
end
