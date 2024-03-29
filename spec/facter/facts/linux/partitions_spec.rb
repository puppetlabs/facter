# frozen_string_literal: true

describe Facts::Linux::Partitions do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Partitions.new }

    let(:mountpoints_resolver_output) do
      [{ available: '63.31 GiB',
         available_bytes: 67_979_685_888,
         capacity: '84.64%',
         device: '/dev/sda1',
         filesystem: 'ext4',
         options: %w[rw noatime],
         path: '/',
         size: '434.42 GiB',
         size_bytes: 466_449_743_872,
         used: '348.97 GiB',
         used_bytes: 374_704_357_376 }]
    end
    let(:partitions_resolver_output) do
      { '/dev/sda1' => { 'filesystem' => 'ext3', 'label' => '/boot', 'size' => '203.89 KiB', 'size_bytes' => 208_782,
                         'uuid' => '88077904-4fd4-476f-9af2-0f7a806ca25e' } }
    end

    let(:final_result) do
      { '/dev/sda1' => { 'filesystem' => 'ext3', 'label' => '/boot', 'size' => '203.89 KiB', 'size_bytes' => 208_782,
                         'uuid' => '88077904-4fd4-476f-9af2-0f7a806ca25e', 'mount' => '/' } }
    end

    context 'when resolver returns hash' do
      before do
        allow(Facter::Resolvers::Mountpoints).to receive(:resolve).with(:mountpoints)
                                                                  .and_return(mountpoints_resolver_output)
        allow(Facter::Resolvers::Partitions).to receive(:resolve).with(:partitions)
                                                                 .and_return(partitions_resolver_output)
      end

      it 'returns partitions information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'partitions', value: final_result)
      end
    end

    context 'when mountpoints resolver returns nil' do
      before do
        allow(Facter::Resolvers::Mountpoints).to receive(:resolve).with(:mountpoints).and_return(nil)
        allow(Facter::Resolvers::Partitions).to receive(:resolve).with(:partitions)
                                                                 .and_return(partitions_resolver_output)
      end

      it 'returns partition information without mount info' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'partitions', value: partitions_resolver_output)
      end
    end

    context 'when partitions resolver returns empty hash' do
      before do
        allow(Facter::Resolvers::Mountpoints).to receive(:resolve).with(:mountpoints)
                                                                  .and_return(mountpoints_resolver_output)
        allow(Facter::Resolvers::Partitions).to receive(:resolve).with(:partitions).and_return({})
      end

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'partitions', value: nil)
      end
    end

    context 'when the same device is mounted in multiple places' do
      let(:mountpoints_resolver_output) do
        [{
          device: '/dev/sda2',
          filesystem: 'btrfs',
          path: '/',
          options: ['rw', 'relatime', 'space_cache', 'subvolid=267', 'subvol=/@/.snapshots/1/snapshot'],
          available: '10.74 GiB',
          available_bytes: 11_534_614_528,
          size: '13.09 GiB',
          size_bytes: 14_050_918_400,
          used: '1.96 GiB',
          used_bytes: 2_101_231_616,
          capacity: '15.41%'
        }, {
          device: '/dev/sda2',
          filesystem: 'btrfs',
          path: '/boot/grub2/x86_64-efi',
          options: ['rw', 'relatime', 'space_cache', 'subvolid=264', 'subvol=/@/boot/grub2/x86_64-efi'],
          available: '10.74 GiB',
          available_bytes: 11_534_614_528,
          size: '13.09 GiB',
          size_bytes: 14_050_918_400,
          used: '1.96 GiB',
          used_bytes: 2_101_231_616,
          capacity: '15.41%'
        }]
      end

      let(:partitions_resolver_output) do
        {
          '/dev/sda2' => {
            size_bytes: 14_050_918_400,
            size: '13.09 GiB',
            filesystem: 'btrfs',
            uuid: 'bbc18fba-8191-48c8-b8bd-30373654bb3e',
            partuuid: 'c96cd2ea-1046-461c-b0fe-1e5aa19aba61'
          }
        }
      end

      let(:final_result) do
        {
          '/dev/sda2' => {
            'size_bytes' => 14_050_918_400,
            'size' => '13.09 GiB',
            'filesystem' => 'btrfs',
            'uuid' => 'bbc18fba-8191-48c8-b8bd-30373654bb3e',
            'partuuid' => 'c96cd2ea-1046-461c-b0fe-1e5aa19aba61',
            'mount' => '/'
          }
        }
      end

      before do
        allow(Facter::Resolvers::Mountpoints).to receive(:resolve).with(:mountpoints)
                                                                  .and_return(mountpoints_resolver_output)
        allow(Facter::Resolvers::Partitions).to receive(:resolve).with(:partitions)
                                                                 .and_return(partitions_resolver_output)
      end

      it 'returns partitions information from the first mountpoint' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'partitions', value: final_result)
      end
    end
  end
end
