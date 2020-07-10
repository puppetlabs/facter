# frozen_string_literal: true

describe Facts::Macosx::Filesystems do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Filesystems.new }

    let(:value) { 'apfs,autofs,devfs' }

    before do
      allow(Facter::Resolvers::Macosx::Filesystems).to receive(:resolve).with(:macosx_filesystems).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::Filesystems' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Filesystems).to have_received(:resolve).with(:macosx_filesystems)
    end

    it 'returns filesystems fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'filesystems', value: value)
    end
  end
end
