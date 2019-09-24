# frozen_string_literal: true

describe 'RedHatReleaseResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('cat /etc/redhat-release')
      .and_return("Red Hat Enterprise Linux Server release 5.10 (Tikanga)\n")
  end

  it 'returns os NAME' do
    result = Facter::Resolvers::RedHatRelease.resolve(:name)

    expect(result).to eq('Red Hat Enterprise Linux Server')
  end

  it 'returns os VERSION_ID' do
    result = Facter::Resolvers::RedHatRelease.resolve(:version)

    expect(result).to eq('5.10')
  end

  it 'returns os VERSION_CODENAME' do
    result = Facter::Resolvers::RedHatRelease.resolve(:codename)

    expect(result).to eq('Tikanga')
  end
end
