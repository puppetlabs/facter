# frozen_string_literal: true

describe Facter::Resolvers::Linux::Hostname do
  subject(:hostname_resolver) { Facter::Resolvers::Linux::Hostname }

  shared_examples 'detects values' do
    it 'detects hostname' do
      expect(hostname_resolver.resolve(:hostname)).to eq(hostname)
    end

    it 'returns networking domain' do
      expect(hostname_resolver.resolve(:domain)).to eq(domain)
    end

    it 'returns fqdn' do
      expect(hostname_resolver.resolve(:fqdn)).to eq(fqdn)
    end
  end

  describe '#resolve' do
    before do
      allow(Socket).to receive(:gethostname).and_return(host)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/resolv.conf')
        .and_return("nameserver 10.10.0.10\nnameserver 10.10.1.10\nsearch baz\ndomain baz\n")
    end

    after do
      hostname_resolver.invalidate_cache
    end

    context 'when ruby socket hostname works' do
      let(:hostname) { 'foo' }
      let(:domain) { 'bar' }
      let(:fqdn) { "#{hostname}.#{domain}" }

      context 'when it returns fqdn' do
        let(:host) { "#{hostname}.#{domain}" }

        it_behaves_like 'detects values'
      end

      context 'when it returns only the hostname and ruby addrinfo works' do
        let(:host) { hostname }
        let(:addr_info) { [['', '', "#{hostname}.#{domain}", '']] }

        before do
          allow(Socket).to receive(:getaddrinfo).and_return(addr_info)
        end

        it_behaves_like 'detects values'
      end

      context 'when it returns only the hostname and ruby addrinfo fails' do
        let(:host) { hostname }
        let(:output) { fqdn }

        before do
          allow(Socket).to receive(:getaddrinfo).and_return([])
          allow(Facter::Util::Resolvers::Ffi::Hostname).to receive(:getffiaddrinfo).and_return(output)
        end

        it_behaves_like 'detects values'

        context 'when ffi addrinfo fails' do
          let(:output) { nil }
          let(:resolv_conf) { "domain #{domain}" }

          before do
            allow(Facter::Util::FileHelper).to receive(:safe_read).with('/etc/resolv.conf').and_return(resolv_conf)
          end

          it_behaves_like 'detects values'

          context 'when /etc/resolv.conf is empty' do
            let(:resolv_conf) { '' }
            let(:domain) { nil }
            let(:fqdn) { hostname }

            it_behaves_like 'detects values'
          end

          context 'when /etc/resolv.conf has "search ."' do
            let(:resolv_conf) { "search .\n" }
            let(:domain) { nil }
            let(:fqdn) { hostname }

            it_behaves_like 'detects values'
          end

          context 'when /etc/resolv.conf has "search ." with multiple entires' do
            let(:resolv_conf) { 'search . foo.bar' }
            let(:domain) { nil }
            let(:fqdn) { hostname }

            it_behaves_like 'detects values'
          end

          context 'when /etc/resolv.conf has "search" with multiple entires' do
            let(:resolv_conf) { 'search foo.bar example.com' }
            let(:domain) { 'foo.bar' }
            let(:fqdn) { "#{hostname}.#{domain}" }

            it_behaves_like 'detects values'
          end
        end

        context 'when FFI is not installed' do
          before do
            allow(Socket).to receive(:gethostname).and_return(nil)
            allow(Facter::Resolvers::Linux::Hostname).to receive(:require_relative).and_call_original
            allow(Facter::Resolvers::Linux::Hostname).to receive(:require_relative)
              .with('../../../facter/util/resolvers/ffi/hostname')
              .and_raise(LoadError, 'cannot load ffi')
          end

          it 'logs that ffi canot be loaded' do
            allow(hostname_resolver.log).to receive(:debug)
            expect(hostname_resolver.log).to receive(:debug).with('cannot load ffi')

            hostname_resolver.resolve(:hostname)
          end

          it 'does not resolve hostname' do
            expect(hostname_resolver.resolve(:hostname)).to be_nil
          end

          it 'does not resolve domain' do
            expect(hostname_resolver.resolve(:domain)).to be_nil
          end

          it 'does not resolve fqdn' do
            expect(hostname_resolver.resolve(:fqdn)).to be_nil
          end
        end
      end
    end

    context 'when ruby socket hostname fails' do
      let(:hostname) { 'hostnametest' }
      let(:domain) { 'domaintest' }
      let(:fqdn) { "#{hostname}.#{domain}" }
      let(:host) { '' }

      before do
        allow(Facter::Util::Resolvers::Ffi::Hostname).to receive(:getffihostname).and_return(ffi_host)
      end

      context 'when ffi hostname works' do
        let(:ffi_host) { fqdn }

        it_behaves_like 'detects values'
      end

      context 'when it returns only the hostname and ruby addrinfo works' do
        let(:addr_info) { [['', '', "#{hostname}.#{domain}", '']] }
        let(:ffi_host) { hostname }

        before do
          allow(Socket).to receive(:getaddrinfo).and_return(addr_info)
        end

        it_behaves_like 'detects values'
      end

      context 'when it returns only the hostname and ruby addrinfo fails' do
        let(:ffi_host) { hostname }
        let(:output) { fqdn }

        before do
          allow(Socket).to receive(:getaddrinfo).and_return([])
          allow(Facter::Util::Resolvers::Ffi::Hostname).to receive(:getffiaddrinfo).and_return(output)
        end

        it_behaves_like 'detects values'

        context 'when ffi addrinfo fails' do
          let(:output) { nil }
          let(:resolv_conf) { "domain #{domain}" }

          before do
            allow(Facter::Util::FileHelper).to receive(:safe_read).with('/etc/resolv.conf').and_return(resolv_conf)
          end

          it_behaves_like 'detects values'

          context 'when /etc/resolv.conf is empty' do
            let(:resolv_conf) { '' }
            let(:domain) { nil }
            let(:fqdn) { hostname }

            it_behaves_like 'detects values'
          end
        end

        context 'when ffi is not installed' do
          let(:host) { hostname }
          let(:resolv_conf) { "domain #{domain}" }

          before do
            allow(Socket).to receive(:gethostname).and_return(host)
            allow(Facter::Util::FileHelper).to receive(:safe_read).with('/etc/resolv.conf').and_return(resolv_conf)
            allow(Facter::Resolvers::Linux::Hostname).to receive(:require_relative).and_call_original

            allow(Facter::Resolvers::Linux::Hostname).to receive(:require_relative)
              .with('../../../facter/util/resolvers/ffi/hostname')
              .and_raise(LoadError, 'cannot load ffi')
          end

          it 'logs that ffi canot be loaded' do
            allow(hostname_resolver.log).to receive(:debug)
            expect(hostname_resolver.log).to receive(:debug).with('cannot load ffi')

            hostname_resolver.resolve(:domain)
          end

          it_behaves_like 'detects values'

          context 'when /etc/resolv.conf is empty' do
            let(:resolv_conf) { '' }
            let(:domain) { nil }
            let(:fqdn) { hostname }

            it_behaves_like 'detects values'
          end
        end
      end
    end

    context 'when ffi hostname fails to return hostname' do
      let(:hostname) { nil }
      let(:domain) { nil }
      let(:host) { '' }
      let(:fqdn) { nil }

      before do
        allow(Facter::Util::Resolvers::Ffi::Hostname).to receive(:getffihostname).and_return('')
      end

      it_behaves_like 'detects values'
    end

    context 'when FFI is not installed' do
      let(:hostname) { nil }
      let(:domain) { nil }
      let(:host) { '' }
      let(:fqdn) { nil }

      before do
        allow(Facter::Resolvers::Linux::Hostname).to receive(:require_relative).and_call_original
        allow(Facter::Resolvers::Linux::Hostname).to receive(:require_relative)
          .with('../../../facter/util/resolvers/ffi/hostname')
          .and_raise(LoadError, 'cannot load ffi')
      end

      it 'logs that ffi canot be loaded' do
        allow(hostname_resolver.log).to receive(:debug)
        expect(hostname_resolver.log).to receive(:debug).with('cannot load ffi')

        hostname_resolver.resolve(:hostname)
      end

      it_behaves_like 'detects values'
    end
  end
end
