# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Filesystems do
  subject(:filesystems_resolver) { Facter::Resolvers::Macosx::Filesystems }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    filesystems_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute).with('mount', logger: log_spy)
                                                       .and_return(load_fixture('macosx_filesystems'))
  end

  describe '#call_the_resolver' do
    let(:filesystems) { 'apfs,autofs,devfs' }

    it 'returns systems' do
      expect(filesystems_resolver.resolve(:macosx_filesystems)).to eq(filesystems)
    end
  end
end
