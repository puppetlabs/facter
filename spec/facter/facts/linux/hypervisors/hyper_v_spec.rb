# frozen_string_literal: true

describe Facts::Linux::Hypervisors::HyperV do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Hypervisors::HyperV.new }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return(manufacturer)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(product_name)
    end

    context 'when resolver returns hyper_v' do
      let(:manufacturer) { 'Microsoft' }
      let(:product_name) { 'Virtual Machine' }
      let(:value) { {} }

      it 'calls Facter::Resolvers::DMIBios with :sys_vendor' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:sys_vendor)
      end

      it 'calls Facter::Resolvers::DMIBios with :product_name' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name)
      end

      it 'returns hyper_v fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.hyperv', value: value)
      end
    end

    context 'when resolver returns nil' do
      let(:manufacturer) { nil }
      let(:product_name) { nil }
      let(:value) { nil }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.hyperv', value: value)
      end
    end

    context 'when manufacturer is not Microsoft' do
      let(:manufacturer) { 'unknown' }
      let(:product_name) { 'Virtual Machine' }
      let(:value) { nil }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.hyperv', value: value)
      end
    end

    context 'when manufacturer is Microsoft and product name is not Virtual Machine' do
      let(:manufacturer) { 'Microsoft' }
      let(:product_name) { 'something_else' }
      let(:value) { nil }

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.hyperv', value: value)
      end
    end
  end
end
