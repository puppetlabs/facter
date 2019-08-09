# frozen_string_literal: true

require 'spec_helper'

include RSpec

describe 'OsResolver' do
  before do
    allow(Open3).to receive(:capture2).
      with('uname -a').
      and_return('Darwin mbp.wifi.tsr.corp.puppet.net 18.2.0 Darwin Kernel Version 18.2.0: Fri Oct  5 19:41:49 PDT 2018; root:xnu-4903.221.2~2/RELEASE_X86_64 x86_64')
  end
  it 'returns os family' do
    result = OsResolver.resolve(:family)

    expect(result).to eq('Darwin')
  end

  it 'returns os name' do
    result = OsResolver.resolve(:name)

    expect(result).to eq('Darwin')
  end

  it 'returns os release' do
    result = OsResolver.resolve(:release)

    expect(result).to eq('18.2.0')
  end
end
