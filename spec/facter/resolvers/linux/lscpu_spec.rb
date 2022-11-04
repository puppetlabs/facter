# frozen_string_literal: true

describe Facter::Resolvers::Linux::Lscpu do
  before do
    Facter::Resolvers::Linux::Lscpu.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with("lscpu | grep -e 'Thread(s)' -e 'Core(s)'", { logger: log_spy })
      .and_return(lscpu_output)
  end

  after do
    Facter::Resolvers::Linux::Lscpu.invalidate_cache
  end

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:cores_per_socket) { 1 }
  let(:threads_per_core) { 2 }
  let(:lscpu_output) do
    ["'Thread(s) per core': 2",
     "'Cores(s) per socket': 1"].join("\n")
  end

  it 'returns cores per socket' do
    result = Facter::Resolvers::Linux::Lscpu.resolve(:cores_per_socket)

    expect(result).to eq(cores_per_socket)
  end

  it 'returns threads per core' do
    result = Facter::Resolvers::Linux::Lscpu.resolve(:threads_per_core)

    expect(result).to eq(threads_per_core)
  end
end
