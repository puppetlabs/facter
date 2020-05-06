# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Processors do
  subject(:processors_resolver) { Facter::Resolvers::Macosx::Processors }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:logicalcount) { 4 }
  let(:models) do
    ['Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz', 'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz',
     'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz', 'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz']
  end
  let(:physical_processors) { 1 }
  let(:speed_expected) { 2_300_000_000 }

  let(:output) do
    ['hw.logicalcpu_max: 4',
     'hw.physicalcpu_max: 1',
     'machdep.cpu.brand_string: Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz',
     'hw.cpufrequency_max: 2300000000'].join("\n")
  end

  before do
    processors_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('sysctl hw.logicalcpu_max hw.physicalcpu_max machdep.cpu.brand_string hw.cpufrequency_max', logger: log_spy)
      .and_return(output)
  end

  it 'returns number of processors' do
    expect(processors_resolver.resolve(:logicalcount)).to eq(logicalcount)
  end

  it 'returns number of physical processors' do
    expect(processors_resolver.resolve(:physicalcount)).to eq(physical_processors)
  end

  it 'returns list of models' do
    expect(processors_resolver.resolve(:models)).to eq(models)
  end

  it 'returns speed of processors' do
    expect(processors_resolver.resolve(:speed)).to eq(speed_expected)
  end
end
