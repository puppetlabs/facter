# frozen_string_literal: true

describe Facts::Aix::Identity::User do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Identity::User.new }

    let(:value) { 'root' }

    before do
      allow(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:user).and_return(value)
    end

    it 'returns id and identity user fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'identity.user', value: value),
                        an_object_having_attributes(name: 'id', value: value, type: :legacy))
    end
  end
end
