# frozen_string_literal: true

describe Facter::Resolvers::Freebsd::FreebsdVersion do
  subject(:freebsd_version) { Facter::Resolvers::Freebsd::FreebsdVersion }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/bin/freebsd-version -kru', logger: freebsd_version.log)
      .and_return('13.0-CURRENT
        12.1-RELEASE-p3
        12.0-STABLE')
  end

  it 'returns installed kernel' do
    expect(freebsd_version.resolve(:installed_kernel)).to eq('13.0-CURRENT')
  end

  it 'returns running kernel' do
    expect(freebsd_version.resolve(:running_kernel)).to eq('12.1-RELEASE-p3')
  end

  it 'returns installed userland' do
    expect(freebsd_version.resolve(:installed_userland)).to eq('12.0-STABLE')
  end
end
