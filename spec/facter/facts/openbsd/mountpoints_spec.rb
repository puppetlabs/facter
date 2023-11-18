# frozen_string_literal: true

describe Facts::Openbsd::Mountpoints do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::Mountpoints.new }

    context 'when resolver returns hash' do
      let(:resolver_output) do
        { '/var': { available: '15.18 GiB',
                    available_bytes: 16_299_800_576,
                    capacity: '12.49%',
                    device: '/dev/sd0j',
                    filesystem: 'ffs',
                    options: %w[local nodev nosuid],
                    size: '18.40 GiB',
                    size_bytes: 19_754_121_216,
                    used: '2.30 GiB',
                    used_bytes: 2_466_615_296 } }
      end
      let(:parsed_fact) do
        { '/var' => { 'available' => '15.18 GiB',
                      'available_bytes' => 16_299_800_576,
                      'capacity' => '12.49%',
                      'device' => '/dev/sd0j',
                      'filesystem' => 'ffs',
                      'options' => %w[local nodev nosuid],
                      'size' => '18.40 GiB',
                      'size_bytes' => 19_754_121_216,
                      'used' => '2.30 GiB',
                      'used_bytes' => 2_466_615_296 } }
      end

      before do
        allow(Facter::Resolvers::Openbsd::Mountpoints).to \
          receive(:resolve).with(:mountpoints).and_return(resolver_output)
      end

      it 'calls Facter::Resolvers::Openbsd::Mountpoints' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Openbsd::Mountpoints).to \
          have_received(:resolve).with(:mountpoints)
      end

      it 'returns mountpoints information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'mountpoints', value: parsed_fact)
      end
    end

    context 'when resolver returns nil' do
      before do
        allow(Facter::Resolvers::Openbsd::Mountpoints).to \
          receive(:resolve).with(:mountpoints).and_return(nil)
      end

      it 'returns mountpoints information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'mountpoints', value: nil)
      end
    end
  end
end
