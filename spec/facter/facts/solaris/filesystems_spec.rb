# frozen_string_literal: true

describe Facts::Solaris::Filesystems do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Filesystems.new }

    let(:files) { 'apfs,autofs,devfs' }

    before do
      allow(Facter::Resolvers::Solaris::Filesystem).to \
        receive(:resolve).with(:file_systems).and_return(files)
    end

    it 'calls Facter::Resolvers::Solaris::Filesystem' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Filesystem).to have_received(:resolve).with(:file_systems)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'filesystems', value: files)
    end
  end
end
