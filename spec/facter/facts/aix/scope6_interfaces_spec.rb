# frozen_string_literal: true

describe Facts::Aix::Scope6Interfaces do
  subject(:fact) { Facts::Aix::Scope6Interfaces.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:scope6).and_return(primary)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { scope6: 'link' }, 'en1' => { scope6: 'global' } } }
    let(:primary) { 'link' }

    it 'calls Facter::Resolvers::Aix::Networking with interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'calls Facter::Resolvers::Aix::Networking with primary' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:scope6)
    end

    it 'returns legacy facts with scope6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'scope6_eth0',
                                                    value: interfaces['eth0'][:scope6], type: :legacy),
                        an_object_having_attributes(name: 'scope6_en1',
                                                    value: interfaces['en1'][:scope6], type: :legacy),
                        an_object_having_attributes(name: 'scope6',
                                                    value: primary, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }
    let(:primary) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
