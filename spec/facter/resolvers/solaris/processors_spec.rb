# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Processors do
  subject(:resolver) { Facter::Resolvers::Solaris::Processors }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    allow(File).to receive(:executable?).with('/usr/bin/kstat').and_return(status)
    allow(Open3)
      .to receive(:capture3)
      .with('/usr/bin/kstat -m cpu_info')
      .and_return(output)

    resolver.instance_variable_set(:@log, log_spy)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when kstat is present and can retrieve information' do
    let(:logicalcount) { 2 }
    let(:models) do
      ['Intel(r) Xeon(r) Gold 6138 CPU @ 2.00GHz', 'Intel(r) Xeon(r) Gold 6138 CPU @ 2.00GHz']
    end
    let(:physical_processors) { 2 }
    let(:speed_expected) { 1_995_246_617 }
    let(:output) { [load_fixture('kstat_cpu').read, '', 0] }
    let(:status) { true }

    it 'returns number of processors' do
      expect(resolver.resolve(:logical_count)).to eq(logicalcount)
    end

    it 'returns number of physical processors' do
      expect(resolver.resolve(:physical_count)).to eq(physical_processors)
    end

    it 'returns list of models' do
      expect(resolver.resolve(:models)).to eq(models)
    end

    it 'returns speed of processors' do
      expect(resolver.resolve(:speed)).to eq(speed_expected)
    end
  end

  context 'when kstat is not present' do
    let(:output) {}
    let(:status) { false }

    it 'returns nil' do
      expect(resolver.resolve(:models)).to be_nil
    end
  end

  context 'when kstat is present but fails' do
    let(:output) { ['', 'kstat failed!', 1] }
    let(:status) { true }

    it 'returns nil' do
      expect(resolver.resolve(:models)).to be_nil
    end

    it 'logs error message' do
      resolver.resolve(:models)

      expect(log_spy).to have_received(:debug).with('Command /usr/bin/kstat failed '\
                                                                                   'with error message: kstat failed!')
    end
  end
end
