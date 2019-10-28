# frozen_string_literal: true

describe 'MemoryResolver' do
  let(:total) { 4_036_680 * 1024 }
  let(:free) { 3_547_792 * 1024 }
  let(:used) { total - free }
  let(:swap_total) { 2_097_148 * 1024 }
  let(:swap_free) { 2_097_148 * 1024 }
  let(:swap_used) { swap_total - swap_free }

  before do
    allow(File).to receive(:read)
      .with('/proc/meminfo')
      .and_return(load_fixture('meminfo').read)
  end
  it 'returns total memory' do
    result = Facter::Resolvers::Linux::Memory.resolve(:total)

    expect(result).to eq(total)
  end

  it 'returns memfree' do
    result = Facter::Resolvers::Linux::Memory.resolve(:memfree)

    expect(result).to eq(free)
  end

  it 'returns swap total' do
    result = Facter::Resolvers::Linux::Memory.resolve(:swap_total)

    expect(result).to eq(swap_total)
  end

  it 'returns swap available' do
    result = Facter::Resolvers::Linux::Memory.resolve(:swap_free)

    expect(result).to eq(swap_free)
  end

  it 'returns swap capacity' do
    result = Facter::Resolvers::Linux::Memory.resolve(:swap_capacity)
    swap_capacity = format('%.2f', (swap_used / swap_total.to_f * 100)) + '%'

    expect(result).to eq(swap_capacity)
  end

  it 'returns swap usage' do
    result = Facter::Resolvers::Linux::Memory.resolve(:swap_used_bytes)

    expect(result).to eq(swap_used)
  end

  it 'returns system capacity' do
    result = Facter::Resolvers::Linux::Memory.resolve(:capacity)
    system_capacity = format('%.2f', (used / total.to_f * 100)) + '%'

    expect(result).to eq(system_capacity)
  end

  it 'returns system usage' do
    result = Facter::Resolvers::Linux::Memory.resolve(:used_bytes)

    expect(result).to eq(used)
  end
end
