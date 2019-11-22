# frozen_string_literal: true

describe 'Fedora DiskSr0Vendor' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'disk.sr0.vendor', value: 'value')
      allow(Facter::Resolvers::Linux::Disk).to receive(:resolve).with(:sr0_vendor).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('disk.sr0.vendor', 'value').and_return(expected_fact)

      fact = Facter::Fedora::DiskSr0Vendor.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
