# frozen_string_literal: true

describe Facter::Resolvers::Lpar do
  before do
    lparstat_i = load_fixture('lparstat_i').read
    allow(Open3).to receive(:capture2)
      .with('/usr/bin/lparstat -i')
      .and_return(lparstat_i)
    Facter::Resolvers::Lpar.invalidate_cache
  end

  it 'returns lpar' do
    expect(Facter::Resolvers::Lpar.resolve(:lpar_partition_name))   .to eq('aix61-6')
    expect(Facter::Resolvers::Lpar.resolve(:lpar_partition_number)) .to eq(15)
  end
end
