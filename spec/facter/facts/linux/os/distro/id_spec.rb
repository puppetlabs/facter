# frozen_string_literal: true

describe Facts::Linux::Os::Distro::Id do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Os::Distro::Id.new }

    let(:value) { 'CentOS' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return(value)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.distro.id', value: value),
                        an_object_having_attributes(name: 'lsbdistid', value: value, type: :legacy))
    end
  end
end
