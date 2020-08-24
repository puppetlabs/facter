# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Filesystem do
  subject(:filesystems_resolver) { Facter::Resolvers::Solaris::Filesystem }

  let(:filesystems) { 'hsfs,nfs,pcfs,udfs,ufs' }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    filesystems_resolver.instance_variable_set(:@log, log_spy)
    allow(File).to receive(:executable?).with('/usr/sbin/sysdef').and_return(true)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/sbin/sysdef', logger: log_spy)
      .and_return(load_fixture('solaris_filesystems').read)
  end

  it 'returns filesystems' do
    expect(filesystems_resolver.resolve(:file_systems)).to eq(filesystems)
  end
end
