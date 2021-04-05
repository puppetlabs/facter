# frozen_string_literal: true

describe Facter::Resolvers::Linux::Processors do
  after do
    Facter::Resolvers::Linux::Processors.invalidate_cache
  end

  context 'when on x86 architecture' do
    let(:log_spy) { instance_spy(Facter::Log) }
    let(:processors) { 4 }
    let(:models) do
      ['Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz', 'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz',
       'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz', 'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz']
    end
    let(:physical_processors) { 1 }
    let(:cores_per_socket){ 1 }
    let(:threads_per_core){ 2 }
    let(:lscpu_output) do
      ["| grep -e 'Thread(s)': 2",
       "-e 'Cores(s)': 1"
      ].join("\n")
    end

    

    context 'when cpuinfo file is readable' do
      before do
        Facter::Resolvers::Linux::ProcessorsLscpu.instance_variable_set(:@log, log_spy)
        allow(Facter::Util::FileHelper).to receive(:safe_readlines)
          .with('/proc/cpuinfo')
          .and_return(load_fixture('cpuinfo').readlines)

        allow(Facter::Core::Execution)
          .to receive(:execute)
          .with("lscpu | grep -e 'Thread(s)' -e 'Core(s)'", logger: log_spy)
          .and_return(lscpu_output)
      end

      let(:speed) { 2_294_000_000 }

      it 'returns number of processors' do
        result = Facter::Resolvers::Linux::Processors.resolve(:processors)

        expect(result).to eq(processors)
      end

      it 'returns list of models' do
        result = Facter::Resolvers::Linux::Processors.resolve(:models)

        expect(result).to eq(models)
      end

      it 'returns number of physical processors' do
        result = Facter::Resolvers::Linux::Processors.resolve(:physical_count)

        expect(result).to eq(physical_processors)
      end

      it 'returns cpu speed' do
        result = Facter::Resolvers::Linux::Processors.resolve(:speed)

        expect(result).to eq(speed)
      end

      it 'returns cores per socket' do
        result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:cores_per_socket)

        expect(result).to eq(cores_per_socket)
      end

      it 'returns threads per core' do
        result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:threads_per_core)

        expect(result).to eq(threads_per_core)
      end
    end

    context 'when cpuinfo file is readable but no physical id' do
      before do
        Facter::Resolvers::Linux::ProcessorsLscpu.instance_variable_set(:@log, log_spy)
        allow(Facter::Util::FileHelper).to receive(:safe_readlines)
          .with('/proc/cpuinfo')
          .and_return(load_fixture('cpuinfo_wo_physical_id').readlines)
        allow(Dir).to receive(:entries).with('/sys/devices/system/cpu').and_return(%w[cpu0 cpu1 cpuindex])

        allow(File).to receive(:exist?)
          .with('/sys/devices/system/cpu/cpu0/topology/physical_package_id')
          .and_return(true)

        allow(File).to receive(:exist?)
          .with('/sys/devices/system/cpu/cpu1/topology/physical_package_id')
          .and_return(true)

        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/sys/devices/system/cpu/cpu0/topology/physical_package_id')
          .and_return('0')

        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/sys/devices/system/cpu/cpu1/topology/physical_package_id')
          .and_return('1')

        allow(Facter::Core::Execution)
          .to receive(:execute)
          .with("lscpu | grep -e 'Thread(s)' -e 'Core(s)'", logger: log_spy)
          .and_return(lscpu_output)
      end

      after do
        Facter::Resolvers::Linux::Processors.invalidate_cache
      end

      let(:physical_processors) { 2 }

      it 'returns number of processors' do
        result = Facter::Resolvers::Linux::Processors.resolve(:processors)

        expect(result).to eq(processors)
      end

      it 'returns list of models' do
        result = Facter::Resolvers::Linux::Processors.resolve(:models)

        expect(result).to eq(models)
      end

      it 'returns number of physical processors' do
        result = Facter::Resolvers::Linux::Processors.resolve(:physical_count)

        expect(result).to eq(physical_processors)
      end

      it 'returns cores per socket' do
        result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:cores_per_socket)

        expect(result).to eq(cores_per_socket)
      end

      it 'returns threads per core' do
        result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:threads_per_core)

        expect(result).to eq(threads_per_core)
      end
    end

    context 'when cpuinfo is not readable' do
      before do
        Facter::Resolvers::Linux::ProcessorsLscpu.instance_variable_set(:@log, log_spy)
        allow(Facter::Util::FileHelper).to receive(:safe_readlines)
          .with('/proc/cpuinfo')
          .and_return([])

        allow(Facter::Core::Execution)
          .to receive(:execute)
          .with("lscpu | grep -e 'Thread(s)' -e 'Core(s)'", logger: log_spy)
          .and_return(lscpu_output)
      end

      it 'returns nil' do
        result = Facter::Resolvers::Linux::Processors.resolve(:physical_count)

        expect(result).to be(nil)
      end

      it 'returns cores per socket without cpuinfo' do
        result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:cores_per_socket)

        expect(result).to eq(cores_per_socket)
      end

      it 'returns threads per core without cpuinfo' do
        result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:threads_per_core)

        expect(result).to eq(threads_per_core)
      end
    end
  end

  context 'when on powerpc architecture' do
    before do
      Facter::Resolvers::Linux::ProcessorsLscpu.instance_variable_set(:@log, log_spy)
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/proc/cpuinfo')
        .and_return(load_fixture('cpuinfo_powerpc').readlines)

      allow(Dir).to receive(:entries).with('/sys/devices/system/cpu').and_return(%w[cpu0 cpu1 cpuindex])
      allow(File).to receive(:exist?).with('/sys/devices/system/cpu/cpu0/topology/physical_package_id').and_return(true)
      allow(File).to receive(:exist?).with('/sys/devices/system/cpu/cpu1/topology/physical_package_id').and_return(true)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/devices/system/cpu/cpu0/topology/physical_package_id')
        .and_return('0')

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/devices/system/cpu/cpu1/topology/physical_package_id')
        .and_return('1')
      
      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with("lscpu | grep -e 'Thread(s)' -e 'Core(s)'", logger: log_spy)
        .and_return(lscpu_output)
    end

    let(:log_spy) { instance_spy(Facter::Log) }
    let(:speed) { 2_926_000_000 }
    let(:physical_processors) { 2 }
    let(:cores_per_socket){ 1 }
    let(:threads_per_core){ 2 }
    let(:lscpu_output) do
      ["| grep -e 'Thread(s)': 2",
       "-e 'Cores(s)': 1"
      ].join("\n")
    end

    let(:models) do
      ['POWER8 (raw), altivec supported',
       'POWER8 (raw), altivec supported',
       'POWER8 (raw), altivec supported',
       'POWER8 (raw), altivec supported']
    end

    it 'returns physical_devices_count' do
      result = Facter::Resolvers::Linux::Processors.resolve(:physical_count)

      expect(result).to eq(physical_processors)
    end

    it 'returns list of models' do
      result = Facter::Resolvers::Linux::Processors.resolve(:models)

      expect(result).to eq(models)
    end

    it 'returns cpu speed' do
      result = Facter::Resolvers::Linux::Processors.resolve(:speed)

      expect(result).to eq(speed)
    end

    it 'returns cores per socket' do
      result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:cores_per_socket)

      expect(result).to eq(cores_per_socket)
    end

    it 'returns threads per core' do
      result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:threads_per_core)

      expect(result).to eq(threads_per_core)
    end
  end

  context 'when on arm64 architecture' do
    before do
      Facter::Resolvers::Linux::ProcessorsLscpu.instance_variable_set(:@log, log_spy)
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/proc/cpuinfo')
        .and_return(load_fixture('cpuinfo_arm64').readlines)

      allow(Dir).to receive(:entries).with('/sys/devices/system/cpu').and_return(%w[cpu0 cpu1 cpuindex])
      allow(File).to receive(:exist?).with('/sys/devices/system/cpu/cpu0/topology/physical_package_id').and_return(true)
      allow(File).to receive(:exist?).with('/sys/devices/system/cpu/cpu1/topology/physical_package_id').and_return(true)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/devices/system/cpu/cpu0/topology/physical_package_id')
        .and_return('0')

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/devices/system/cpu/cpu1/topology/physical_package_id')
        .and_return('0')

      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with("lscpu | grep -e 'Thread(s)' -e 'Core(s)'", logger: log_spy)
        .and_return(lscpu_output)
    end

    let(:log_spy) { instance_spy(Facter::Log) }
    let(:physical_processors) { 1 }
    let(:cores_per_socket){ 1 }
    let(:threads_per_core){ 2 }
    let(:lscpu_output) do
      ["| grep -e 'Thread(s)': 2",
       "-e 'Cores(s)': 1"
      ].join("\n")
    end

    it 'returns physical_devices_count' do
      result = Facter::Resolvers::Linux::Processors.resolve(:physical_count)

      expect(result).to eq(physical_processors)
    end

    it 'returns cores per socket' do
      result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:cores_per_socket)

      expect(result).to eq(cores_per_socket)
    end

    it 'returns threads per core' do
      result = Facter::Resolvers::Linux::ProcessorsLscpu.resolve(:threads_per_core)

      expect(result).to eq(threads_per_core)
    end
  end
end
