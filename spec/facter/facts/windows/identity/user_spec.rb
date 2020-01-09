# frozen_string_literal: true

describe 'Windows IdentityUser' do
  context '#call_the_resolver' do
    let(:value) { 'User\Administrator' }
    subject(:fact) { Facter::Windows::IdentityUser.new }

    before do
      allow(Facter::Resolvers::Identity).to receive(:resolve).with(:user).and_return(value)
    end

    it 'calls Facter::Resolvers::Identity' do
      expect(Facter::Resolvers::Identity).to receive(:resolve).with(:user)
      fact.call_the_resolver
    end

    it 'returns user name' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'identity.user', value: value),
                        an_object_having_attributes(name: 'id', value: value, type: :legacy))
    end
  end
end
