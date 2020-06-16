# frozen_string_literal: true

describe Facts::Freebsd::Disks do
  subject(:fact) { Facts::Freebsd::Disks.new }

  let(:disk) do
    {
      'disks' => {
        'sda' => {
          'model' => 'Virtual disk',
          'size' => '20.00 GiB',
          'size_bytes' => 21_474_836_480,
          'vendor' => 'VMware'
        }
      }
    }
  end

  describe '#call_the_resolver' do
    before do
      allow(Facter::Resolvers::Freebsd::Geom).to receive(:resolve).with(:disks).and_return(disk)
    end

    it 'calls Facter::Resolvers::Freebsd::Disk' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::Geom).to have_received(:resolve).with(:disks)
    end

    it 'returns resolved fact with name disk and value' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'disks', value: disk)
    end
  end
end
