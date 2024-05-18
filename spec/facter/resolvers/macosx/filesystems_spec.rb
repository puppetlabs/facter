# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Filesystems do
  subject(:filesystems_resolver) { Facter::Resolvers::Macosx::Filesystems }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('mount', logger: an_instance_of(Facter::Log))
      .and_return(load_fixture('macosx_filesystems').read)
  end

  describe '#call_the_resolver' do
    let(:filesystems) { 'apfs,autofs,devfs,vmhgfs' }

    it 'returns systems' do
      expect(filesystems_resolver.resolve(:macosx_filesystems)).to eq(filesystems)
    end
  end
end
