# frozen_string_literal: true

describe Facter::Resolvers::Lpar do
  subject(:lpar_resolver) { Facter::Resolvers::Lpar }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/bin/lparstat -i', logger: an_instance_of(Facter::Log))
      .and_return(load_fixture('lparstat_i').read)
    lpar_resolver.invalidate_cache
  end

  it 'returns lpar pratition number' do
    expect(lpar_resolver.resolve(:lpar_partition_number)).to eq(15)
  end

  it 'returns lpar pratition name' do
    expect(lpar_resolver.resolve(:lpar_partition_name)).to eq('aix61-6')
  end
end
