# frozen_string_literal: true

describe 'Windows ProcessorsResolver' do
  context '#resolve' do
    before do
      win = double('Win32Ole')
      proccesors = double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 2)

      allow(Win32Ole).to receive(:new).and_return(win)
      allow(win).to receive(:exec_query).with('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
                                        .and_return([proccesors])
    end
    after do
      ProcessorsResolver.invalidate_cache
    end

    it 'should detect models' do
      expect(ProcessorsResolver.resolve(:models)).to eql(['Pretty_Name'])
    end
    it 'should detect isa' do
      expect(ProcessorsResolver.resolve(:isa)).to eql('x86')
    end
    it 'should count proccesors' do
      expect(ProcessorsResolver.resolve(:count)).to eql(2)
    end
    it 'should calculate physical count' do
      expect(ProcessorsResolver.resolve(:physicalcount)).to eql(1)
    end
  end

  context '#resolve when number of logical processors is 0' do
    before do
      win = double('Win32Ole')
      processor1 = double('proc', Name: 'Pretty_Name', Architecture: 0, NumberOfLogicalProcessors: 0)
      processor2 = double('proc', Name: 'Awesome_Name', Architecture: 10, NumberOfLogicalProcessors: 0)

      allow(Win32Ole).to receive(:new).and_return(win)
      allow(win).to receive(:exec_query).with('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
                                        .and_return([processor1, processor2])
    end
    after do
      ProcessorsResolver.invalidate_cache
    end

    it 'should detect models' do
      expect(ProcessorsResolver.resolve(:models)).to eql(%w[Pretty_Name Awesome_Name])
    end
    it 'should detect isa' do
      expect(ProcessorsResolver.resolve(:isa)).to eql('x86')
    end
    it 'should count proccesors' do
      expect(ProcessorsResolver.resolve(:count)).to eql(2)
    end
    it 'should calculate physical count' do
      expect(ProcessorsResolver.resolve(:physicalcount)).to eql(2)
    end
  end

  context '#resolve is raising error when is an unknown architecture' do
    before do
      win = double('Win32Ole')
      processor = double('proc', Name: 'Pretty_Name', Architecture: 10, NumberOfLogicalProcessors: 0)

      allow(Win32Ole).to receive(:new).and_return(win)
      allow(win).to receive(:exec_query).with('SELECT Name,Architecture,NumberOfLogicalProcessors FROM Win32_Processor')
                                        .and_return([processor])
    end

    it 'should raise error' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Unable to determine processor type: unknown architecture')
      ProcessorsResolver.resolve(:isa)
    end
  end
end
