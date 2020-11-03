# frozen_string_literal: true

describe Facts::Aix::Identity::Group do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Identity::Group.new }

    let(:value) { 'staff' }

    before do
      allow(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:cache_group).and_return(value)
    end

    it 'calls Facter::Resolvers::PosxIdentity' do
      fact.call_the_resolver
      expect(Facter::Resolvers::PosxIdentity).to have_received(:resolve).with(:cache_group)
    end

    it 'returns identity group fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'identity.group', value: value),
                        an_object_having_attributes(name: 'gid', value: value, type: :legacy))
    end
  end
end
