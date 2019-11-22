# frozen_string_literal: true

describe 'Fedora DiskSr0SizeBytes' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'disk.sr0.size_bytes', value: 'value')
      allow(Facter::Resolvers::Linux::Disk).to receive(:resolve).with(:sr0_size).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('disk.sr0.size_bytes', 'value').and_return(expected_fact)

      fact = Facter::Fedora::DiskSr0SizeBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
