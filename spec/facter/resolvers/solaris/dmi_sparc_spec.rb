# frozen_string_literal: true

describe Facter::Resolvers::Solaris::DmiSparc do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Solaris::DmiSparc }

    let(:log_spy) { instance_spy(Facter::Log) }

    before do
      resolver.instance_variable_set(:@log, log_spy)
      allow(File).to receive(:executable?).with('/usr/sbin/prtdiag').and_return(true)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('/usr/sbin/prtdiag', logger: log_spy)
        .and_return(load_fixture('prtdiag').read)
      allow(File).to receive(:executable?).with('/usr/sbin/sneep').and_return(true)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('/usr/sbin/sneep', logger: log_spy).and_return('random_string')
    end

    after do
      Facter::Resolvers::Solaris::DmiSparc.invalidate_cache
    end

    it 'returns manufacturer' do
      expect(resolver.resolve(:manufacturer)).to eq('Oracle Corporation')
    end

    it 'returns product_name' do
      expect(resolver.resolve(:product_name)).to eq('SPARC T7-1')
    end

    it 'returns serial_number' do
      expect(resolver.resolve(:serial_number)).to eq('random_string')
    end
  end
end
