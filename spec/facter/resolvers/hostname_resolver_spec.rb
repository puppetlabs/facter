# frozen_string_literal: true

describe Facter::Resolvers::Hostname do
  subject(:hostname_resolver) { Facter::Resolvers::Hostname }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#resolve' do
    before do
      hostname_resolver.instance_variable_set(:@log, log_spy)
      allow(Socket).to receive(:gethostname).and_return(host)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/resolv.conf')
        .and_return("nameserver 10.10.0.10\nnameserver 10.10.1.10\nsearch baz\ndomain baz\n")
    end

    after do
      hostname_resolver.invalidate_cache
    end

    context 'when hostname returns fqdn' do
      let(:hostname) { 'foo' }
      let(:domain) { 'bar' }
      let(:host) { "#{hostname}.#{domain}" }
      let(:fqdn) { "#{hostname}.#{domain}" }

      it 'detects hostname' do
        expect(hostname_resolver.resolve(:hostname)).to eql(hostname)
      end

      it 'returns networking Domain' do
        expect(hostname_resolver.resolve(:domain)).to eq(domain)
      end

      it 'returns fqdn' do
        expect(hostname_resolver.resolve(:fqdn)).to eq(fqdn)
      end
    end

    context 'when hostname returns host' do
      let(:hostname) { 'foo' }
      let(:domain) { 'baz' }
      let(:host) { hostname }
      let(:fqdn) { "#{hostname}.#{domain}" }

      before do
        allow(Socket).to receive(:getaddrinfo).and_return(domain)
      end

      it 'detects hostname' do
        expect(hostname_resolver.resolve(:hostname)).to eql(hostname)
      end

      it 'returns networking Domain' do
        expect(hostname_resolver.resolve(:domain)).to eq(domain)
      end

      it 'returns fqdn' do
        expect(hostname_resolver.resolve(:fqdn)).to eq(fqdn)
      end
    end

    context 'when hostname could not be retrieved' do
      let(:host) { nil }

      it 'detects that hostname is nil' do
        expect(hostname_resolver.resolve(:hostname)).to be(nil)
      end
    end

    context 'when /etc/resolve.conf is inaccessible' do
      let(:host) { 'foo' }
      let(:domain) { '' }

      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with('/etc/resolv.conf').and_return('')
        allow(Socket).to receive(:getaddrinfo).and_return(domain)
      end

      it 'detects that domain is nil' do
        expect(hostname_resolver.resolve(:domain)).to be(nil)
      end
    end
  end
end
