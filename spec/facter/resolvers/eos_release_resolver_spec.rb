# frozen_string_literal: true

describe Facter::Resolvers::EosRelease do
  subject(:eos_release) { Facter::Resolvers::EosRelease }

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/etc/Eos-release', nil)
      .and_return('name version')
  end

  it 'returns name' do
    expect(eos_release.resolve(:name)).to eq('name')
  end

  it 'returns version' do
    expect(eos_release.resolve(:version)).to eq('version')
  end
end
