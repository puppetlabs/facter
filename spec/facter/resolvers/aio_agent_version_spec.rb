# frozen_string_literal: true

describe Facter::Resolvers::AioAgentVersion do
  describe '#resolve' do
    before do
      allow(Facter::Util::FileHelper)
        .to receive(:safe_read)
        .with('/opt/puppetlabs/puppet/VERSION', nil)
        .and_return('7.0.1')
    end

    after do
      Facter::Resolvers::AioAgentVersion.invalidate_cache
    end

    it 'calls FileHelper.safe_read' do
      Facter::Resolvers::AioAgentVersion.resolve(:aio_agent_version)

      expect(Facter::Util::FileHelper).to have_received(:safe_read).with('/opt/puppetlabs/puppet/VERSION', nil)
    end

    it 'detects puppet version' do
      expect(Facter::Resolvers::AioAgentVersion.resolve(:aio_agent_version)).to eql('7.0.1')
    end

    context 'when AIO puppet agent is a dev build' do
      before do
        allow(Facter::Util::FileHelper)
          .to receive(:safe_read)
          .with('/opt/puppetlabs/puppet/VERSION', nil)
          .and_return('7.0.1.8.g12345678')
      end

      it 'only shows the first 4 groups of digits' do
        expect(Facter::Resolvers::AioAgentVersion.resolve(:aio_agent_version)).to eql('7.0.1.8')
      end
    end

    context 'when there is no AIO puppet agent' do
      before do
        allow(Facter::Util::FileHelper)
          .to receive(:safe_read)
          .with('/opt/puppetlabs/puppet/VERSION', nil)
          .and_return(nil)
      end

      it 'resolves to nil' do
        expect(Facter::Resolvers::AioAgentVersion.resolve(:aio_agent_version)).to be(nil)
      end
    end
  end
end
