# frozen_string_literal: true

describe Facter::Windows::Network6Interfaces do
  subject(:fact) { Facter::Windows::Network6Interfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { network6: '::1' }, 'en1' => { network6: 'fe80::' } } }

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces)
      fact.call_the_resolver
    end

    it 'returns legacy facts with names network6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'network6_eth0',
                                                    value: interfaces['eth0'][:network6], type: :legacy),
                        an_object_having_attributes(name: 'network6_en1',
                                                    value: interfaces['en1'][:network6], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
