# frozen_string_literal: true

describe Facts::Solaris::Disks do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Disks.new }

    let(:value) do
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
      allow(Facter::Resolvers::Solaris::Disks).to receive(:resolve).with(:disks).and_return(value)
    end

    it 'calls Facter::Resolvers::Solaris::Disks' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Disks).to have_received(:resolve).with(:disks)
    end

    it 'returns disks fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'disks', value: value)
    end
  end
end
