# frozen_string_literal: true

describe Facter::Aix::OsRelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Aix::OsRelease.new }

    let(:value) { '12.0.1 ' }

    before do
      allow(Facter::Resolvers::OsLevel).to receive(:resolve).with(:build).and_return(value)
    end

    it 'calls Facter::Resolvers::OsLevel' do
      expect(Facter::Resolvers::OsLevel).to receive(:resolve).with(:build)
      fact.call_the_resolver
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: { full: value.strip,
                                                                                 major: value.split('-')[0] }),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: value.split('-')[0],
                                                    type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value.strip, type: :legacy))
    end
  end
end
