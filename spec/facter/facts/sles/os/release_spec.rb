# frozen_string_literal: true

describe 'Sles OsRelease' do
  context '#call_the_resolver' do
    let(:value) { '10.0' }
    subject(:fact) { Facter::Sles::OsRelease.new }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return('10')
    end

    it 'calls Facter::Resolvers::OsRelease' do
      expect(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id)
      fact.call_the_resolver
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: { full: value, major: '10', minor: 0 }),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: '10', type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
    end
  end
end
