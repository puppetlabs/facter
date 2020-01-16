# frozen_string_literal: true

describe 'Fedora Filesystems' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'ext2,ext3,ext4,xfs'
      expected_fact = double(Facter::ResolvedFact, name: 'filesystems', value: value)
      allow(Facter::Resolvers::Linux::Filesystems).to receive(:resolve).with(:systems).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('filesystems', value).and_return(expected_fact)

      fact = Facter::El::Filesystems.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
