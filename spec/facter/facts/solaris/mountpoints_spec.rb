# frozen_string_literal: true

describe Facts::Solaris::Mountpoints do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Mountpoints.new }

    context 'when resolver returns hash' do
      let(:resolver_output) do
        [{ available: '5.59 GiB',
           available_bytes: 6_006_294_016,
           capacity: '41.76%',
           device: 'rpool/ROOT/solaris',
           filesystem: 'zfs',
           options: ['dev=4490002'],
           path: '/',
           size: '9.61 GiB',
           size_bytes: 10_313_577_472,
           used: '4.01 GiB',
           used_bytes: 4_307_283_456 }]
      end

      let(:parsed_fact) do
        { '/' => { 'available' => '5.59 GiB',
                   'available_bytes' => 6_006_294_016,
                   'capacity' => '41.76%',
                   'device' => 'rpool/ROOT/solaris',
                   'filesystem' => 'zfs',
                   'options' => ['dev=4490002'],
                   'size' => '9.61 GiB',
                   'size_bytes' => 10_313_577_472,
                   'used' => '4.01 GiB',
                   'used_bytes' => 4_307_283_456 } }
      end

      before do
        allow(Facter::Resolvers::Solaris::Mountpoints)
          .to receive(:resolve).with(:mountpoints).and_return(resolver_output)
      end

      it 'calls Facter::Resolvers::Mountpoints' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::Mountpoints).to have_received(:resolve).with(:mountpoints)
      end

      it 'returns mountpoints information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'mountpoints', value: parsed_fact)
      end
    end

    context 'when resolver returns nil' do
      before do
        allow(Facter::Resolvers::Solaris::Mountpoints).to receive(:resolve).with(:mountpoints).and_return(nil)
      end

      it 'returns mountpoints information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'mountpoints', value: nil)
      end
    end
  end
end
