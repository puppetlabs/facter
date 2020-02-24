# frozen_string_literal: true

describe Facter::Macosx::Mountpoints do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::Mountpoints.new }

    context 'when resolver returns hash' do
      let(:resolver_output) do
        { '/': { available: '63.31 GiB',
                 available_bytes: 67_979_685_888,
                 capacity: '84.64%',
                 device: '/dev/nvme0n1p2',
                 filesystem: 'ext4',
                 options: %w[rw noatime],
                 size: '434.42 GiB',
                 size_bytes: 466_449_743_872,
                 used: '348.97 GiB',
                 used_bytes: 374_704_357_376 } }
      end

      let(:parsed_fact) do
        { '/': { available: '63.31 GiB',
                 available_bytes: 67_979_685_888,
                 capacity: '84.64%',
                 device: '/dev/nvme0n1p2',
                 filesystem: 'ext4',
                 options: %w[rw noatime],
                 size: '434.42 GiB',
                 size_bytes: 466_449_743_872,
                 used: '348.97 GiB',
                 used_bytes: 374_704_357_376 } }
      end

      before do
        allow(Facter::Resolvers::Macosx::Mountpoints).to \
          receive(:resolve).with(:mountpoints).and_return(resolver_output)
      end

      it 'calls Facter::Resolvers::Macosx::Mountpoints' do
        expect(Facter::Resolvers::Macosx::Mountpoints).to receive(:resolve).with(:mountpoints)
        fact.call_the_resolver
      end

      it 'returns mountpoints information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'mountpoints', value: parsed_fact)
      end
    end

    context 'when resolver returns nil' do
      before do
        allow(Facter::Resolvers::Macosx::Mountpoints).to receive(:resolve).with(:mountpoints).and_return(nil)
      end

      it 'returns mountpoints information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'mountpoints', value: nil)
      end
    end
  end
end
