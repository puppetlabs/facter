# frozen_string_literal: true

describe Facter::Resolvers::Uname do
  subject(:uname_resolver) { Facter::Resolvers::Uname }

  let(:log_spy) { Facter::Log }

  before do
    uname_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('uname -m &&
            uname -n &&
            uname -p &&
            uname -r &&
            uname -s &&
            uname -v', logger: log_spy)
      .and_return('x86_64
        wifi.tsr.corp.puppet.net
        i386
        18.2.0
        Darwin
        Darwin Kernel Version 18.2.0: Fri Oct  5 19:41:49 PDT 2018; root:xnu-4903.221.2~2/RELEASE_X86_64')
  end

  it 'returns machine' do
    expect(uname_resolver.resolve(:machine)).to eq('x86_64')
  end

  it 'returns nodename' do
    expect(uname_resolver.resolve(:nodename)).to eq('wifi.tsr.corp.puppet.net')
  end

  it 'returns processor' do
    expect(uname_resolver.resolve(:processor)).to eq('i386')
  end

  it 'returns kernelrelease' do
    expect(uname_resolver.resolve(:kernelrelease)).to eq('18.2.0')
  end

  it 'returns kernelname' do
    expect(uname_resolver.resolve(:kernelname)).to eq('Darwin')
  end

  it 'returns kernelversion' do
    expect(uname_resolver.resolve(:kernelversion)).to include('root:xnu-4903.221.2~2/RELEASE_X86_64')
  end
end
