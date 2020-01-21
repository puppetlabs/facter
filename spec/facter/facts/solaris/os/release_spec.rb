# frozen_string_literal: true

describe 'Solaris OsRelease' do
  context '#call_the_resolver' do
    let(:value) { { full: '10_u11', minor: '11', major: '10' } }
    subject(:fact) { Facter::Solaris::OsRelease.new }

    before do
      allow(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:full).and_return('10_u11')
      allow(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:major).and_return('10')
      allow(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:minor).and_return('11')
    end

    it 'calls Facter::Resolvers::OsRelease' do
      expect(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:full)
      expect(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:major)
      expect(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:minor)
      fact.call_the_resolver
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: value),
                        an_object_having_attributes(name: 'operatingsystemmajrelease',
                                                    value: value[:major], type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value[:full], type: :legacy))
    end
  end
end
