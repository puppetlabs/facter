# frozen_string_literal: true

describe Facter::Resolvers::Lpar do
  subject(:lpar_resolver) { Facter::Resolvers::Lpar }

  before do
    lparstat_i = load_fixture('lparstat_i').read
    allow(Open3).to receive(:capture2)
      .with('/usr/bin/lparstat -i')
      .and_return(lparstat_i)
    lpar_resolver.invalidate_cache
  end

  it 'returns lpar pratition number' do
    expect(lpar_resolver.resolve(:lpar_partition_number)) .to eq(15)
  end

  it 'returns lpar pratition name' do
    expect(lpar_resolver.resolve(:lpar_partition_name)).to eq('aix61-6')
  end
end
