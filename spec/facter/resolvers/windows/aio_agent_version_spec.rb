# frozen_string_literal: true

describe Facter::Resolvers::Windows::AioAgentVersion do
  describe '#resolve' do
    subject(:aio_agent_resolver) { Facter::Resolvers::Windows::AioAgentVersion }

    let(:puppet_version) { '7.0.1' }
    let(:reg) { instance_spy(Win32::Registry::HKEY_LOCAL_MACHINE) }
    let(:log) { instance_spy(Facter::Log) }

    before do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open).with('SOFTWARE\\Puppet Labs\\Puppet').and_yield(reg)
      allow(Facter::Util::FileHelper)
        .to receive(:safe_read)
        .with('path_to_puppet/VERSION', nil)
        .and_return(puppet_version)
      allow(Facter::Resolvers::BaseResolver).to receive(:log).and_return(log)
    end

    after do
      Facter::Resolvers::Windows::AioAgentVersion.invalidate_cache
    end

    context 'when the registry path is incorrect' do
      before do
        allow(Win32::Registry::HKEY_LOCAL_MACHINE)
          .to receive(:open)
          .with('SOFTWARE\\Puppet Labs\\Puppet')
          .and_raise(Win32::Registry::Error)
      end

      it 'logs debug message specific to none existent path' do
        aio_agent_resolver.resolve(:aio_agent_version)

        expect(log).to have_received(:debug).with('The registry path SOFTWARE\Puppet Labs\Puppet does not exist')
      end
    end

    context 'when windows is 64 bit edition' do
      before do
        allow(reg).to receive(:read).with('RememberedInstallDir64').and_return([1, 'path_to_puppet'])
      end

      it 'returns path from registry specific to 64 bit windows' do
        expect(aio_agent_resolver.resolve(:aio_agent_version)).to eq(puppet_version)
      end

      context 'when RememberedInstallDir64 does not contain a value' do
        before do
          allow(reg).to receive(:read).with('RememberedInstallDir64').and_return([1, ''])
        end

        it 'calls file helper with empty path' do
          expect(aio_agent_resolver.resolve(:aio_agent_version)).to be(nil)
        end
      end

      context 'when AIO puppet agent is a dev build' do
        before do
          allow(Facter::Util::FileHelper)
            .to receive(:safe_read)
            .with('path_to_puppet/VERSION', nil)
            .and_return('7.0.1.8.g12345678')
        end

        it 'only shows the first 4 groups of digits' do
          expect(aio_agent_resolver.resolve(:aio_agent_version)).to eql('7.0.1.8')
        end
      end
    end

    context 'when windows is 32 bit edition' do
      before do
        allow(reg).to receive(:read).with('RememberedInstallDir64').and_raise(Win32::Registry::Error)
        allow(reg).to receive(:read).with('RememberedInstallDir').and_return([1, 'path_to_puppet'])
      end

      it 'logs debug message for 64 bit register' do
        aio_agent_resolver.resolve(:aio_agent_version)

        expect(log).to have_received(:debug).with('Could not read Puppet AIO path from 64 bit registry')
      end

      it 'returns path from registry specific to 32 bit windows' do
        expect(aio_agent_resolver.resolve(:aio_agent_version)).to eq(puppet_version)
      end

      context 'when there is no registry entry for 32 bit version' do
        before do
          allow(reg).to receive(:read).with('RememberedInstallDir').and_raise(Win32::Registry::Error)
        end

        it 'logs debug error for 32 bit registry' do
          aio_agent_resolver.resolve(:aio_agent_version)

          expect(log).to have_received(:debug).with('Could not read Puppet AIO path from 32 bit registry')
        end
      end
    end
  end
end
