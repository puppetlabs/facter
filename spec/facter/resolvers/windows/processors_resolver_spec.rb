# frozen_string_literal: true

describe Facter::Resolvers::Processors do
  subject(:resolver) { Facter::Resolvers::Processors }

  let(:logger) { instance_spy(Facter::Log) }

  before do
    win = double('Facter::Util::Windows::Win32Ole')

    allow(Facter::Util::Windows::Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
                                      .and_return(proc)
    resolver.instance_variable_set(:@log, logger)
  end

  after do
    resolver.invalidate_cache
  end

  describe '#resolve' do
    let(:proc) { [double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 2)] }

    it 'detects models of processors' do
      expect(resolver.resolve(:models)).to eql(['Pretty_Name'])
    end

    it 'detects isa' do
      expect(resolver.resolve(:isa)).to eql('x86')
    end

    it 'counts proccesors' do
      expect(resolver.resolve(:count)).to be(2)
    end

    it 'counts physical processors' do
      expect(resolver.resolve(:physicalcount)).to be(1)
    end
  end

  describe '#resolve when number of logical processors is 0' do
    let(:proc) do
      [double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 0),
       double('proc', Name: 'Awesome_Name', Architecture: 10, NumberOfLogicalProcessors: 0)]
    end

    it 'detects models' do
      expect(resolver.resolve(:models)).to eql(%w[Pretty_Name Awesome_Name])
    end

    it 'detects isa' do
      expect(resolver.resolve(:isa)).to eql('x86')
    end

    it 'counts proccesors' do
      expect(resolver.resolve(:count)).to be(2)
    end

    it 'counts physical processors' do
      expect(resolver.resolve(:physicalcount)).to be(2)
    end
  end

  describe '#resolve logs a debug message when is an unknown architecture' do
    let(:proc) { [double('proc', Name: 'Pretty_Name', Architecture: 10, NumberOfLogicalProcessors: 0)] }

    it 'logs that is unknown architecture' do
      allow(logger).to receive(:debug)
        .with('Unable to determine processor type: unknown architecture')
      expect(resolver.resolve(:isa)).to be(nil)
    end
  end

  describe '#resolve when WMI query returns nil' do
    let(:proc) { nil }

    it 'logs that query failed and isa nil' do
      allow(logger).to receive(:debug)
        .with('WMI query returned no results'\
        'for Win32_Processor with values Name, Architecture and NumberOfLogicalProcessors.')
      expect(resolver.resolve(:isa)).to be(nil)
    end

    it 'detects that models fact is nil' do
      expect(resolver.resolve(:models)).to be(nil)
    end

    it 'detects that count fact is nil' do
      expect(resolver.resolve(:count)).to be(nil)
    end

    it 'detects that physicalcount fact is nil' do
      expect(resolver.resolve(:physicalcount)).to be(nil)
    end
  end

  describe '#resolve when WMI query returns nil for Name, Architecture and NumberOfLogicalProcessors' do
    let(:proc) { [double('proc', Name: nil, Architecture: nil, NumberOfLogicalProcessors: nil)] }

    it 'detects that isa is nil' do
      allow(logger).to receive(:debug)
        .with('Unable to determine processor type: unknown architecture')
      expect(resolver.resolve(:isa)).to be(nil)
    end

    it 'detects that models is an array' do
      expect(resolver.resolve(:models)).to eql([nil])
    end

    it 'detects count fact' do
      expect(resolver.resolve(:count)).to be(1)
    end

    it 'detects physicalcount' do
      expect(resolver.resolve(:physicalcount)).to be(1)
    end
  end
end
