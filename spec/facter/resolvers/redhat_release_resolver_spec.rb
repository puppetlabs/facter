# frozen_string_literal: true

describe Facter::Resolvers::RedHatRelease do
  subject(:redhat_release) { Facter::Resolvers::RedHatRelease }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/etc/redhat-release', nil)
      .and_return("Red Hat Enterprise Linux Server release 5.10 (Tikanga)\n")
  end

  it 'returns os NAME' do
    expect(redhat_release.resolve(:name)).to eq('RedHat')
  end

  it 'returns os VERSION_ID' do
    expect(redhat_release.resolve(:version)).to eq('5.10')
  end

  it 'returns os VERSION_CODENAME' do
    expect(redhat_release.resolve(:codename)).to eq('Tikanga')
  end
end
