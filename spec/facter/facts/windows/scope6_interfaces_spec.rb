# frozen_string_literal: true

describe 'Windows Scope6Interfaces' do
  context '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { scope6: 'link' }, 'en1' => { scope6: 'global' } } }
    subject(:fact) { Facter::Windows::Scope6Interfaces.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces)
      fact.call_the_resolver
    end

    it 'returns legacy facts with scope6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'scope6_eth0',
                                                    value: interfaces['eth0'][:scope6], type: :legacy),
                        an_object_having_attributes(name: 'scope6_en1',
                                                    value: interfaces['en1'][:scope6], type: :legacy))
    end
  end
end
