# frozen_string_literal: true

describe 'Windows OsHardware' do
  context '#call_the_resolver' do
    let(:value) { 'x86_64' }
    subject(:fact) { Facter::Windows::OsHardware.new }

    before do
      allow(Facter::Resolvers::HardwareArchitecture).to receive(:resolve).with(:hardware).and_return(value)
    end

    it 'calls Facter::Resolvers::HardwareArchitecture' do
      expect(Facter::Resolvers::HardwareArchitecture).to receive(:resolve).with(:hardware)
      fact.call_the_resolver
    end

    it 'returns hardware model fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.hardware', value: value),
                        an_object_having_attributes(name: 'hardwaremodel', value: value, type: :legacy))
    end
  end
end
