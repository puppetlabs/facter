# frozen_string_literal: true

describe 'LsbReleaseResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('lsb_release -a')
      .and_return("Distributor ID:\tUbuntu\nDescription:\tUbuntu 18.04.1 LTS\nRelease:\t18.04\nCodename:\tbionic\n")
  end

  it 'returns os Distributor ID' do
    result = Facter::Resolver::LsbReleaseResolver.resolve('Distributor ID')

    expect(result).to eq('Ubuntu')
  end

  it 'returns os Description' do
    result = Facter::Resolver::LsbReleaseResolver.resolve('Description')

    expect(result).to eq('Ubuntu 18.04.1 LTS')
  end

  it 'returns os release' do
    result = Facter::Resolver::LsbReleaseResolver.resolve('Release')

    expect(result).to eq('18.04')
  end

  it 'returns os Codename' do
    result = Facter::Resolver::LsbReleaseResolver.resolve('Codename')

    expect(result).to eq('bionic')
  end
end
