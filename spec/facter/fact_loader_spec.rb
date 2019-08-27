# frozen_string_literal: true

describe '.loads facts for OS' do
  it 'loads one legacy fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([:NetworkInterface])
    fact_hash = Facter::FactLoader.load(:ubuntu)
    network_interface_class = Class.const_get('Facter::Ubuntu::NetworkInterface')

    expect(fact_hash['networking.interface']).to eq(network_interface_class)
  end

  it 'loads one non legacy fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([:OsName])
    fact_hash = Facter::FactLoader.load(:ubuntu)
    network_interface_class = Class.const_get('Facter::Ubuntu::OsName')

    expect(fact_hash['os.name']).to eq(network_interface_class)
  end

  it 'does not load any fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([])
    fact_hash = Facter::FactLoader.load_with_legacy(:ubuntu)

    expect(fact_hash.size).to eq(0)
  end
end
