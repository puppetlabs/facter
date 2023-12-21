# frozen_string_literal: true

describe Facts::Sles::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Distro::Release.new }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve)
        .with(:version_id)
        .and_return(value)
    end

    context 'when version has .' do
      let(:value) { '12.1' }
      let(:release) { { 'full' => '12.1', 'major' => '12', 'minor' => '1' } }

      it 'returns operating system name fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: release),
                          an_object_having_attributes(name: 'lsbdistrelease',
                                                      value: release['full'], type: :legacy),
                          an_object_having_attributes(name: 'lsbmajdistrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'lsbminordistrelease',
                                                      value: release['minor'], type: :legacy))
      end
    end

    context 'when version is simple' do
      let(:value) { '15' }
      let(:release) { { 'full' => '15', 'major' => '15', 'minor' => nil } }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(value)
      end

      it 'returns operating system name fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: release),
                          an_object_having_attributes(name: 'lsbdistrelease',
                                                      value: release['full'], type: :legacy),
                          an_object_having_attributes(name: 'lsbmajdistrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'lsbminordistrelease',
                                                      value: release['minor'], type: :legacy))
      end
    end
  end
end
