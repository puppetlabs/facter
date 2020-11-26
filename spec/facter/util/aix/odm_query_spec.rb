# frozen_string_literal: true

describe Facter::Util::Aix::ODMQuery do
  let(:odm_query) { Facter::Util::Aix::ODMQuery.new }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    odm_query.instance_variable_set(:@log, log_spy)
    stub_const('Facter::Util::Aix::ODMQuery::REPOS', ['CuAt'])
  end

  it 'creates a query' do
    odm_query.equals('name', '12345')

    expect(Facter::Core::Execution).to receive(:execute).with("odmget -q \"name='12345'\" CuAt", logger: log_spy)
    odm_query.execute
  end

  it 'can chain conditions' do
    odm_query.equals('field1', 'value').like('field2', 'value*')

    expect(Facter::Core::Execution).to receive(:execute)
      .with("odmget -q \"field1='value' AND field2 like 'value*'\" CuAt", logger: log_spy)
    odm_query.execute
  end
end
