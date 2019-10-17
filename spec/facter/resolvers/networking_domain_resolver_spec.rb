# frozen_string_literal: true

describe 'NetworkingDomain' do
  before do
    allow(File).to receive(:read)
      .with('/etc/resolv.conf')
      .and_return("nameserver 10.10.0.10\nnameserver 10.10.1.10\nsearch puppetlabs.net\n")
  end
  it 'returns networking Domain' do
    expect(Facter::Resolvers::NetworkingDomain.resolve(:networking_domain)).to eq('puppetlabs.net')
  end
end
