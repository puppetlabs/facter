# frozen_string_literal: true

describe Facter::Resolvers::Hostname do
  describe '#resolve' do
    before do
      allow(Open3).to receive(:capture2).with('hostname').and_return(host)
      allow(File).to receive(:exist?).with('/etc/resolv.conf').and_return(true)
      allow(File).to receive(:read)
        .with('/etc/resolv.conf')
        .and_return("nameserver 10.10.0.10\nnameserver 10.10.1.10\nsearch baz\ndomain baz\n")
    end

    after do
      Facter::Resolvers::Hostname.invalidate_cache
    end

    context 'when hostname returns fqdn' do
      let(:hostname) { 'foo' }
      let(:domain) { 'bar' }
      let(:host) { "#{hostname}.#{domain}" }
      let(:fqdn) { "#{hostname}.#{domain}" }

      it 'detects hostname' do
        expect(Facter::Resolvers::Hostname.resolve(:hostname)).to eql(hostname)
      end

      it 'returns networking Domain' do
        expect(Facter::Resolvers::Hostname.resolve(:domain)).to eq(domain)
      end

      it 'returns fqdn' do
        expect(Facter::Resolvers::Hostname.resolve(:fqdn)).to eq(fqdn)
      end
    end

    context 'when hostname returns host' do
      let(:hostname) { 'foo' }
      let(:domain) { 'baz' }
      let(:host) { hostname }
      let(:fqdn) { "#{hostname}.#{domain}" }

      it 'detects hostname' do
        expect(Facter::Resolvers::Hostname.resolve(:hostname)).to eql(hostname)
      end

      it 'returns networking Domain' do
        expect(Facter::Resolvers::Hostname.resolve(:domain)).to eq(domain)
      end

      it 'returns fqdn' do
        expect(Facter::Resolvers::Hostname.resolve(:fqdn)).to eq(fqdn)
      end
    end

    context 'when hostname could not be retrieved' do
      let(:host) { nil }

      it 'detects that hostname is nil' do
        expect(Facter::Resolvers::Hostname.resolve(:hostname)).to be(nil)
      end
    end
  end
end
