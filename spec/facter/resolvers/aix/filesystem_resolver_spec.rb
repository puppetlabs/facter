# frozen_string_literal: true

describe Facter::Resolvers::Aix::Filesystem do
  let(:filesystems) { 'ahafs,cdrfs,namefs,procfs,sfs' }

  before do
    allow(File).to receive(:readable?).with('/etc/vfs').and_return(true)
    allow(File).to receive(:readlines)
      .with('/etc/vfs')
      .and_return(load_fixture('aix_filesystems').read.split("\n"))
  end

  it 'returns filesystems' do
    result = Facter::Resolvers::Aix::Filesystem.resolve(:file_systems)

    expect(result).to eq(filesystems)
  end
end
