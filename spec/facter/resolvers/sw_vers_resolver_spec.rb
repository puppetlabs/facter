# frozen_string_literal: true

describe Facter::Resolvers::SwVers do
  before do
    allow(Open3).to receive(:capture2)
      .with('sw_vers')
      .and_return("ProductName:\tMac OS X\nProductVersion:\t10.14.1\nBuildVersion:\t18B75\n")
  end

  it 'returns os ProductName' do
    result = Facter::Resolvers::SwVers.resolve(:productname)

    expect(result).to eq('Mac OS X')
  end

  it 'returns os ProductVersion' do
    result = Facter::Resolvers::SwVers.resolve(:productversion)

    expect(result).to eq('10.14.1')
  end

  it 'returns os BuildVersion' do
    result = Facter::Resolvers::SwVers.resolve(:buildversion)

    expect(result).to eq('18B75')
  end
end
