# frozen_string_literal: true

describe 'FilesystemsResolver' do
  before do
    allow(Open3).to receive(:capture2).with('mount').and_return(load_fixture('macosx_filesystems'))
  end
  context '#call_the_resolver' do
    let(:filesystems) { 'apfs,autofs,devfs' }
    it 'returns systems' do
      expect(Facter::Resolvers::Macosx::Filesystems.resolve(:macosx_filesystems)).to eq(filesystems)
    end
  end
end
