# frozen_string_literal: true

describe 'UnameResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('uname -a')
      .and_return('Darwin mbp.wifi.tsr.corp.puppet.net 18.2.0 Darwin Kernel Version 18.2.0: Fri Oct  5
        e19:41:49 PDT 2018; root:xnu-4903.221.2~2/RELEASE_X86_64 x86_64')
  end
  it 'returns os family' do
    result = UnameResolver.resolve(:family)

    expect(result).to eq('Darwin')
  end

  it 'returns os name' do
    result = UnameResolver.resolve(:name)

    expect(result).to eq('Darwin')
  end

  it 'returns os release' do
    result = UnameResolver.resolve(:release)

    expect(result).to eq('18.2.0')
  end
end
