# frozen_string_literal: true

require 'spec_helper'

include RSpec

describe 'OsResolver' do
  it 'calls Open3 and parses result' do
    allow(Open3).to receive(:capture2).
      with('uname -a').
      and_return('Darwin mbp.wifi.tsr.corp.puppet.net 18.2.0 Darwin Kernel Version 18.2.0: Fri Oct  5 19:41:49 PDT 2018; root:xnu-4903.221.2~2/RELEASE_X86_64 x86_64')

    result = OsResolver.resolve

    expect(result).to eq({:family=>"Darwin", :name=>"Darwin", :release=>{:full=>"18.2.0", :major=>"18", :minor=>"2"}})
  end

  it 'filters result' do
    allow(Open3).to receive(:capture2).
      with('uname -a').
      and_return('Darwin mbp.wifi.tsr.corp.puppet.net 18.2.0 Darwin Kernel Version 18.2.0: Fri Oct  5 19:41:49 PDT 2018; root:xnu-4903.221.2~2/RELEASE_X86_64 x86_64')

    result = OsResolver.resolve(['release', 'full'])

    expect(result).to eq("18.2.0")
  end
end
