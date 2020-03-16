# frozen_string_literal: true

describe Facts::Solaris::SolarisZones::Zone do
  subject(:fact) { Facts::Solaris::SolarisZones::Zone.new }

  let(:zone_name) { 'global' }
  let(:result) do
    { brand: 'solaris',
      id: '0',
      iptype: 'shared',
      name: 'global',
      uuid: nil,
      status: nil,
      path: nil }
  end

  let(:result_fact) do
    { zone_name => { 'brand' => 'solaris',
                     'id' => '0',
                     'ip_type' => 'shared',
                     'status' => nil,
                     'path' => nil } }
  end

  before do
    allow(Facter::Resolvers::SolarisZone).to receive(:resolve).with(:zone).and_return([result])
  end

  describe '#call_the_resolver' do
    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(
          an_object_having_attributes(name: 'solaris_zones.zones', value: result_fact, type: :core),
          an_object_having_attributes(name: 'zone_global_id', value: result[:id], type: :legacy),
          an_object_having_attributes(name: 'zone_global_uuid', value: result[:uuid], type: :legacy),
          an_object_having_attributes(name: 'zone_global_name', value: result[:name], type: :legacy),
          an_object_having_attributes(name: 'zone_global_path', value: result[:path], type: :legacy),
          an_object_having_attributes(name: 'zone_global_status', value: result[:status], type: :legacy),
          an_object_having_attributes(name: 'zone_global_brand', value: result[:brand], type: :legacy),
          an_object_having_attributes(name: 'zone_global_iptype', value: result[:iptype], type: :legacy),
          an_object_having_attributes(name: 'zones', value: 1, type: :legacy)
        )
    end
  end
end
