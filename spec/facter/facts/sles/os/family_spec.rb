# frozen_string_literal: true

describe Facts::Sles::Os::Family do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Family.new }

    let(:value) { 'Suse' }

    it 'returns os family fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.family', value: value),
                        an_object_having_attributes(name: 'osfamily', value: value, type: :legacy))
    end
  end
end
