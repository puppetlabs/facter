# frozen_string_literal: true

describe Facts::Linux::Xen do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Xen.new }

    before do
      allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(vm)
      allow(Facter::Resolvers::Xen).to receive(:resolve).with(:domains).and_return(domains)
    end

    context 'when is xen privileged' do
      let(:vm) { 'xen0' }
      let(:domains) { %w[domain1 domain2] }

      it 'calls Facter::Resolvers::VirtWhat' do
        fact.call_the_resolver
        expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vm)
      end

      it 'calls Facter::Resolvers::Xen with :domains' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:domains)
      end

      it 'returns xen fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'xen', value: { 'domains' => domains }),
                          an_object_having_attributes(name: 'xendomains',
                                                      value: domains.entries.join(','), type: :legacy))
      end
    end

    context 'when is xen privileged but there are no domains' do
      let(:vm) { nil }
      let(:domains) { [] }

      before do
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return('xen0')
      end

      it 'calls Facter::Resolvers::VirtWhat' do
        fact.call_the_resolver
        expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vm)
      end

      it 'calls Facter::Resolvers::Xen with :vm' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:vm)
      end

      it 'calls Facter::Resolvers::Xen with :domains' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:domains)
      end

      it 'returns xen fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'xen', value: { 'domains' => domains }),
                          an_object_having_attributes(name: 'xendomains',
                                                      value: domains.entries.join(','), type: :legacy))
      end
    end

    context 'when is xen privileged but domains are nil' do
      let(:vm) { nil }
      let(:domains) { nil }
      let(:result) { [] }

      before do
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return('xen0')
      end

      it 'calls Facter::Resolvers::VirtWhat' do
        fact.call_the_resolver
        expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vm)
      end

      it 'calls Facter::Resolvers::Xen with :vm' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:vm)
      end

      it 'calls Facter::Resolvers::Xen with :domains' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:domains)
      end

      it 'returns xen fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'xen', value: { 'domains' => result }),
                          an_object_having_attributes(name: 'xendomains',
                                                      value: result.entries.join(','), type: :legacy))
      end
    end

    context 'when is xen unprivileged' do
      let(:vm) { 'xenhvm' }
      let(:domains) { nil }

      it 'calls Facter::Resolvers::VirtWhat' do
        fact.call_the_resolver
        expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vm)
      end

      it 'does not call Facter::Resolvers::Xen with :domains' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Xen).not_to have_received(:resolve).with(:domains)
      end

      it 'returns nil fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'xen', value: domains)
      end
    end
  end
end
