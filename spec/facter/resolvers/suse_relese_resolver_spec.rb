# frozen_string_literal: true

describe Facter::Resolvers::SuseRelease do
  subject(:suse_release) { Facter::Resolvers::SuseRelease }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/etc/SuSE-release', nil)
      .and_return("openSUSE 11.1 (i586)
        VERSION = 11.1")
  end

  it 'returns os NAME' do
    expect(suse_release.resolve(:name)).to eq('openSUSE')
  end

  it 'returns os VERSION_ID' do
    expect(suse_release.resolve(:version)).to eq('11.1')
  end

  it 'returns the identifier' do
    expect(suse_release.resolve(:identifier)).to eq('opensuse')
  end
end
