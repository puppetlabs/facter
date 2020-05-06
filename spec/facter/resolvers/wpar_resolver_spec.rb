# frozen_string_literal: true

describe Facter::Resolvers::Wpar do
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    Facter::Resolvers::Wpar.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/bin/lparstat -W', logger: log_spy)
      .and_return(open3_result)
  end

  after do
    Facter::Resolvers::Wpar.invalidate_cache
  end

  describe '#oslevel 6.1+' do
    let(:open3_result) { load_fixture('lparstat_w').read }

    it 'returns wpar_key' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_key)).to eq(13)
    end

    it 'returns wpar_configured_id' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_configured_id)).to eq(14)
    end
  end

  describe '#oslevel 6.0' do
    let(:open3_result) { '' }

    it 'does not return wpar_key' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_key)).to be_nil
    end

    it 'does not return wpar_configured_id' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_configured_id)).to be_nil
    end
  end
end
