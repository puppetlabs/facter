# frozen_string_literal: true

describe Facts::Aix::Os::Hardware do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Os::Hardware.new }

    let(:value) { 'x86_64' }

    before do
      allow(Facter::Resolvers::Hardware).to receive(:resolve).with(:hardware).and_return(value)
    end

    it 'calls Facter::Resolvers::Hardware' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Hardware).to have_received(:resolve).with(:hardware)
    end

    it 'returns hardware model fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.hardware', value: value),
                        an_object_having_attributes(name: 'hardwaremodel', value: value, type: :legacy))
    end
  end
end
