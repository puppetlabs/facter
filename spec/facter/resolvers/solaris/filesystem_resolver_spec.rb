# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Filesystem do
  let(:filesystems) { 'hsfs,nfs,pcfs,udfs,ufs' }

  before do
    allow(File).to receive(:exist?).with('/usr/sbin/sysdef').and_return(true)
    allow(Open3).to receive(:capture2)
      .with('/usr/sbin/sysdef')
      .and_return(load_fixture('solaris_filesystems').read)
  end

  it 'returns filesystems' do
    result = Facter::Resolvers::Solaris::Filesystem.resolve(:file_systems)

    expect(result).to eq(filesystems)
  end
end
