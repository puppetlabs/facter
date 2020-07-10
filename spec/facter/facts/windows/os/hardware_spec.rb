# frozen_string_literal: true

describe Facts::Windows::Os::Hardware do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Os::Hardware.new }

    let(:value) { 'x86_64' }

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
