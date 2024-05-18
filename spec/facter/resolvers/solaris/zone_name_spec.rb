# frozen_string_literal: true

describe Facter::Resolvers::Solaris::ZoneName do
  subject(:solaris_zone) { Facter::Resolvers::Solaris::ZoneName }

  let(:zone_name_output) { 'global' }

  before do
    allow(File).to receive(:executable?)
      .with('/bin/zonename')
      .and_return(true)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/bin/zonename', logger: an_instance_of(Facter::Log))
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
