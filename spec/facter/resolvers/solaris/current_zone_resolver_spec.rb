# frozen_string_literal: true

describe Facter::Resolvers::SolarisZone do
  before do
    status = double(Process::Status, to_s: st)
    expect(Open3).to receive(:capture2)
      .with('/bin/zonename')
      .ordered
      .and_return([zone_name_output, status])
  end

  after do
    Facter::Resolvers::SolarisZone.invalidate_cache
  end

  context 'Resolve zone facts' do
    let(:zone_name_output) { 'global' }
    let(:st) { 'exit 0' }

    it 'returns zone fact' do
      fact = 'global'
      result = Facter::Resolvers::SolarisZoneName.resolve(:current_zone_name)
      expect(result).to eq(fact)
    end
  end
end
