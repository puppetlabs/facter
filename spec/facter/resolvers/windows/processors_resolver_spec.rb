# frozen_string_literal: true

describe 'Windows ProcessorsResolver' do
  before do
    win = double('Win32Ole')
    proccesors = proc

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
                                      .and_return(proccesors)
  end
  after do
    ProcessorsResolver.invalidate_cache
  end

  context '#resolve' do
    let(:proc) { [double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 2)] }

    it 'detects models of processors' do
      expect(ProcessorsResolver.resolve(:models)).to eql(['Pretty_Name'])
    end
    it 'detects isa' do
      expect(ProcessorsResolver.resolve(:isa)).to eql('x86')
    end
    it 'counts proccesors' do
      expect(ProcessorsResolver.resolve(:count)).to eql(2)
    end
    it 'counts physical processors' do
      expect(ProcessorsResolver.resolve(:physicalcount)).to eql(1)
    end
  end

  context '#resolve when number of logical processors is 0' do
    let(:proc) do
      [double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 0),
       double('proc', Name: 'Awesome_Name', Architecture: 10, NumberOfLogicalProcessors: 0)]
    end

    it 'detects models' do
      expect(ProcessorsResolver.resolve(:models)).to eql(%w[Pretty_Name Awesome_Name])
    end
    it 'detects isa' do
      expect(ProcessorsResolver.resolve(:isa)).to eql('x86')
    end
    it 'counts proccesors' do
      expect(ProcessorsResolver.resolve(:count)).to eql(2)
    end
    it 'counts physical processors' do
      expect(ProcessorsResolver.resolve(:physicalcount)).to eql(2)
    end
  end

  context '#resolve is raising error when is an unknown architecture' do
    let(:proc) { [double('proc', Name: 'Pretty_Name', Architecture: 10, NumberOfLogicalProcessors: 0)] }

    it 'logs that is unknown architecture' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine processor type: unknown architecture')
      ProcessorsResolver.resolve(:isa)
    end
  end
end
