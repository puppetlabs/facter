# frozen_string_literal: true

describe 'SwVersResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('sw_vers')
      .and_return("ProductName:\tMac OS X\nProductVersion:\t10.14.1\nBuildVersion:\t18B75\n")
  end

  it 'returns os ProductName' do
    result = Facter::Resolver::SwVersResolver.resolve('ProductName')

    expect(result).to eq('Mac OS X')
  end

  it 'returns os ProductVersion' do
    result = Facter::Resolver::SwVersResolver.resolve('ProductVersion')

    expect(result).to eq('10.14.1')
  end

  it 'returns os BuildVersion' do
    result = Facter::Resolver::SwVersResolver.resolve('BuildVersion')

    expect(result).to eq('18B75')
  end
end
