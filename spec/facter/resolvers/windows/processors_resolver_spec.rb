# frozen_string_literal: true

describe 'Windows ProcessorsResolver' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
                                      .and_return(proc)
  end
  after do
    Facter::Resolver::ProcessorsResolver.invalidate_cache
  end

  context '#resolve' do
    let(:proc) { [double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 2)] }

    it 'detects models of processors' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:models)).to eql(['Pretty_Name'])
    end
    it 'detects isa' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:isa)).to eql('x86')
    end
    it 'counts proccesors' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:count)).to eql(2)
    end
    it 'counts physical processors' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:physicalcount)).to eql(1)
    end
  end

  context '#resolve when number of logical processors is 0' do
    let(:proc) do
      [double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 0),
       double('proc', Name: 'Awesome_Name', Architecture: 10, NumberOfLogicalProcessors: 0)]
    end

    it 'detects models' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:models)).to eql(%w[Pretty_Name Awesome_Name])
    end
    it 'detects isa' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:isa)).to eql('x86')
    end
    it 'counts proccesors' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:count)).to eql(2)
    end
    it 'counts physical processors' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:physicalcount)).to eql(2)
    end
  end

  context '#resolve logs a debug message when is an unknown architecture' do
    let(:proc) { [double('proc', Name: 'Pretty_Name', Architecture: 10, NumberOfLogicalProcessors: 0)] }

    it 'logs that is unknown architecture' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine processor type: unknown architecture')
      expect(Facter::Resolver::ProcessorsResolver.resolve(:isa)).to eql(nil)
    end
  end

  context '#resolve when WMI query returns nil' do
    let(:proc) { nil }

    it 'logs that query failed and isa nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results'\
        'for Win32_Processor with values Name, Architecture and NumberOfLogicalProcessors.')
      expect(Facter::Resolver::ProcessorsResolver.resolve(:isa)).to eql(nil)
    end
    it 'detects that models, count and physicalcount nil' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:models)).to eql(nil)
      expect(Facter::Resolver::ProcessorsResolver.resolve(:count)).to eql(nil)
      expect(Facter::Resolver::ProcessorsResolver.resolve(:physicalcount)).to eql(nil)
    end
  end

  context '#resolve when WMI query returns nil for Name, Architecture and NumberOfLogicalProcessors' do
    let(:proc) { [double('proc', Name: nil, Architecture: nil, NumberOfLogicalProcessors: nil)] }

    it 'detects that isa is nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine processor type: unknown architecture')
      expect(Facter::Resolver::ProcessorsResolver.resolve(:isa)).to eql(nil)
    end
    it 'detects that models, count and physicalcount nil' do
      expect(Facter::Resolver::ProcessorsResolver.resolve(:models)).to eql([nil])
      expect(Facter::Resolver::ProcessorsResolver.resolve(:count)).to eql(1)
      expect(Facter::Resolver::ProcessorsResolver.resolve(:physicalcount)).to eql(1)
    end
  end
end
