# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Filesystem do
  subject(:filesystems_resolver) { Facter::Resolvers::Solaris::Filesystem }

  let(:filesystems) { 'hsfs,nfs,pcfs,udfs,ufs' }

  before do
    allow(File).to receive(:executable?).with('/usr/sbin/sysdef').and_return(true)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/sbin/sysdef', logger: an_instance_of(Facter::Log))
      .and_return(load_fixture('solaris_filesystems').read)
  end

  it 'returns filesystems' do
    expect(filesystems_resolver.resolve(:file_systems)).to eq(filesystems)
  end
end
