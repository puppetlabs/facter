# frozen_string_literal: true

describe Facter::Resolvers::SolarisZoneName do
  subject(:solaris_zone) { Facter::Resolvers::SolarisZoneName }

  let(:zone_name_output) { 'global' }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    solaris_zone.instance_variable_set(:@log, log_spy)
    allow(File).to receive(:executable?)
      .with('/bin/zonename')
      .and_return(true)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/bin/zonename', logger: log_spy)
      .ordered
      .and_return(zone_name_output)
  end

  after do
    solaris_zone.invalidate_cache
  end

  context 'when can resolve zone facts' do
    it 'returns zone fact' do
      expect(solaris_zone.resolve(:current_zone_name)).to eq(zone_name_output)
    end
  end
end
