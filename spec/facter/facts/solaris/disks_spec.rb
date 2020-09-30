# frozen_string_literal: true

describe Facts::Solaris::Disks do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Disks.new }

    let(:disks) do
      {
        'sd0' => {
          product: 'VMware IDE CDR00Revision',
          size: '0 bytes',
          size_bytes: 0,
          vendor: 'NECVMWar'
        },
        'sd1' => {
          product: 'Virtual disk    Revision',
          size: '20.00 GiB',
          size_bytes: 21_474_836_480,
          vendor: 'VMware'
        }
      }
    end

    let(:expected_response) do
      {
        'sd0' => {
          'product' => 'VMware IDE CDR00Revision',
          'size' => '0 bytes',
          'size_bytes' => 0,
          'vendor' => 'NECVMWar'
        },
        'sd1' => {
          'product' => 'Virtual disk    Revision',
          'size' => '20.00 GiB',
          'size_bytes' => 21_474_836_480,
          'vendor' => 'VMware'
        }
      }
    end

    before do
      allow(Facter::Resolvers::Solaris::Disks).to receive(:resolve).with(:disks).and_return(disks)
    end

    it 'calls Facter::Resolvers::Solaris::Disks' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Disks).to have_received(:resolve).with(:disks)
    end

    it 'returns disks fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Array)
        .and contain_exactly(
          an_object_having_attributes(name: 'disks', value: expected_response),
          an_object_having_attributes(name: 'blockdevices', value: 'sd0,sd1'),
          an_object_having_attributes(name: 'blockdevice_sd0_size', value: 0, type: :legacy),
          an_object_having_attributes(name: 'blockdevice_sd0_vendor', value: 'NECVMWar', type: :legacy),
          an_object_having_attributes(name: 'blockdevice_sd1_size', value: 21_474_836_480, type: :legacy),
          an_object_having_attributes(name: 'blockdevice_sd1_vendor', value: 'VMware', type: :legacy)
        )
    end

    context 'when resolver returns empty hash' do
      let(:disks) { {} }

      it 'returns nil fact' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'disks', value: nil)
      end
    end

    context 'when resolver returns nil' do
      let(:disks) { nil }

      it 'returns nil fact' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'disks', value: nil)
      end
    end
  end
end
