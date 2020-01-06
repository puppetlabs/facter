# frozen_string_literal: true

describe 'Macosx Filesystems' do
  context '#call_the_resolver' do
    let(:value) { 'apfs,autofs,devfs' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'filesystems', value: value) }
    subject(:fact) { Facter::Macosx::Filesystems.new }

    before do
      expect(Facter::Resolvers::Macosx::Filesystems).to receive(:resolve).with(:macosx_filesystems).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('filesystems', value).and_return(expected_resolved_fact)
    end

    it 'returns filesystems fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
