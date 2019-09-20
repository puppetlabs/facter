# frozen_string_literal: true

describe 'Windows HardwareArchitectureResolver' do
  let(:sys_info_ptr) { double('FFI::MemoryPointer') }
  let(:sys_info) { double(SystemInfo) }
  let(:dummyunion) { double(DummyUnionName) }
  let(:dummystruct) { double(DummyStructName) }

  before do
    allow(FFI::MemoryPointer).to receive(:new).with(SystemInfo.size).and_return(sys_info_ptr)
    allow(HardwareFFI).to receive(:GetNativeSystemInfo).with(sys_info_ptr)
    allow(SystemInfo).to receive(:new).with(sys_info_ptr).and_return(sys_info)
    allow(sys_info).to receive(:[]).with(:dummyunionname).and_return(dummyunion)
    allow(dummyunion).to receive(:[]).with(:dummystructname).and_return(dummystruct)
    allow(dummystruct).to receive(:[]).with(:wProcessorArchitecture).and_return(arch)
  end
  after do
    Facter::Resolvers::HardwareArchitectureResolver.invalidate_cache
  end

  context '#resolve when processor is amd64' do
    let(:arch) { HardwareFFI::PROCESSOR_ARCHITECTURE_AMD64 }

    it 'detects hardware' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:hardware)).to eql('x86_64')
    end
    it 'detects architecture' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:architecture)).to eql('x64')
    end
  end

  context '#resolve when processor is arm' do
    let(:arch) { HardwareFFI::PROCESSOR_ARCHITECTURE_ARM }

    it 'detects hardware' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:hardware)).to eql('arm')
    end
    it 'detects architecture' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:architecture)).to eql('arm')
    end
  end

  context '#resolve when processor is ia64' do
    let(:arch) { HardwareFFI::PROCESSOR_ARCHITECTURE_IA64 }

    it 'detects hardware' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:hardware)).to eql('ia64')
    end
    it 'detects architecture' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:architecture)).to eql('ia64')
    end
  end

  context '#resolve when processor is intel and level below 5' do
    before do
      allow(sys_info).to receive(:[]).with(:wProcessorLevel).and_return(level)
    end
    let(:arch) { HardwareFFI::PROCESSOR_ARCHITECTURE_INTEL }
    let(:level) { 4 }

    it 'detects hardware' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:hardware)).to eql("i#{level}86")
    end
    it 'detects architecture' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:architecture)).to eql('x86')
    end
  end

  context '#resolve when processor is intel and level above 5' do
    before do
      allow(sys_info).to receive(:[]).with(:wProcessorLevel).and_return(level)
    end
    let(:arch) { HardwareFFI::PROCESSOR_ARCHITECTURE_INTEL }
    let(:level) { 8 }

    it 'detects hardware' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:hardware)).to eql('i686')
    end
    it 'detects architecture' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:architecture)).to eql('x86')
    end
  end

  context '#resolve when processor unknown' do
    let(:arch) { nil }

    it 'detects hardware' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:hardware)).to eql('unknown')
    end
    it 'detects architecture' do
      expect(Facter::Resolvers::HardwareArchitectureResolver.resolve(:architecture)).to eql('unknown')
    end
  end
end
