# frozen_string_literal: true

describe Facts::Macosx::Filesystems do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Filesystems.new }

    let(:value) { 'apfs,autofs,devfs' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'filesystems', value: value) }

    before do
      expect(Facter::Resolvers::Macosx::Filesystems).to receive(:resolve).with(:macosx_filesystems).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('filesystems', value).and_return(expected_resolved_fact)
    end

    it 'returns filesystems fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
