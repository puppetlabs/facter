# frozen_string_literal: true

describe '.load facts for OS' do
  it 'load one fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([:NetworkInterface])
    fact_hash = Facter::FactLoader.load(:ubuntu, true)
    network_interface_class = Class.const_get('Facter::Ubuntu::NetworkInterface')

    expect(fact_hash['networking.interface']).to eq(network_interface_class)
  end

  it 'does not load any fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([])
    fact_hash = Facter::FactLoader.load(:ubuntu, true)

    expect(fact_hash.size).to eq(0)
  end
end
