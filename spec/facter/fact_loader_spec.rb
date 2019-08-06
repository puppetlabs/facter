# frozen_string_literal: true

RSpec.describe '.load facts for OS' do
  it 'load one fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([:NetworkInterface])
    fact_hash = Facter::FactLoader.load(:linux)

    expect fact_hash.values_at('networking.interface').equal?('Facter::Linux::NetworkInterface')
  end

  it 'does not load any fact' do
    allow_any_instance_of(Module).to receive(:constants).and_return([])
    fact_hash = Facter::FactLoader.load(:linux)

    expect fact_hash.size.equal?(0)
  end
end
