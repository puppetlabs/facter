# frozen_string_literal: true

describe Facter::Resolvers::Linux::Filesystems do
  let(:systems) { 'ext2,ext3,ext4,xfs' }

  before do
    allow(File).to receive(:readable?).with('/proc/filesystems').and_return(true)
    allow(File).to receive(:read)
      .with('/proc/filesystems')
      .and_return(load_fixture('filesystems').read)
  end

  it 'returns systems' do
    result = Facter::Resolvers::Linux::Filesystems.resolve(:systems)

    expect(result).to eq(systems)
  end
end
