# frozen_string_literal: true

describe Facter::Resolvers::Bsd::Processors do
  subject(:resolver) { Facter::Resolvers::Bsd::Processors }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:logicalcount) { 2 }
  let(:models) do
    ['Intel(r) Xeon(r) Gold 6138 CPU @ 2.00GHz', 'Intel(r) Xeon(r) Gold 6138 CPU @ 2.00GHz']
  end
  let(:speed_expected) { 2_592_000_000 }

  before do
    allow(Facter::Bsd::FfiHelper)
      .to receive(:sysctl)
      .with(:uint32_t, [6, 3])
      .and_return(logicalcount)
    allow(Facter::Bsd::FfiHelper)
      .to receive(:sysctl)
      .with(:string, [6, 2])
      .and_return(models[0])
    allow(Facter::Bsd::FfiHelper)
      .to receive(:sysctl)
      .with(:uint32_t, [6, 12])
      .and_return(2592)

    resolver.instance_variable_set(:@log, log_spy)
  end

  after do
    resolver.invalidate_cache
  end

  it 'returns number of processors' do
    expect(resolver.resolve(:logical_count)).to eq(logicalcount)
  end

  it 'returns list of models' do
    expect(resolver.resolve(:models)).to eq(models)
  end

  it 'returns speed of processors' do
    expect(resolver.resolve(:speed)).to eq(speed_expected)
  end
end
