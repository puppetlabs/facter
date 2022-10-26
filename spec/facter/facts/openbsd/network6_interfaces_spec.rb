# frozen_string_literal: true

describe Facts::Openbsd::Network6Interfaces do
  subject(:fact) { Facts::Openbsd::Network6Interfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'em0' => { network6: '::1' }, 'vio0' => { network6: 'fe80::' } } }

    it 'calls Facter::Resolvers::NetworkingOpenBSD' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns legacy facts with names network6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'network6_em0',
                                                    value: interfaces['em0'][:network6], type: :legacy),
                        an_object_having_attributes(name: 'network6_vio0',
                                                    value: interfaces['vio0'][:network6], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
