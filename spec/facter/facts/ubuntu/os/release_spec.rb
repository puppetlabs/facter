# frozen_string_literal: true

describe Facts::Ubuntu::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Ubuntu::Os::Release.new }

    let(:value) { '10.9' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(value)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: { 'full' => value, 'major' => value }),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: value, type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
    end
  end
end
