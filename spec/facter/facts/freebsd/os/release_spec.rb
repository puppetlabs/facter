# frozen_string_literal: true

describe Facts::Freebsd::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Os::Release.new }

    before do
      allow(Facter::Resolvers::Freebsd::FreebsdVersion).to receive(:resolve).with(:installed_userland).and_return(value)
    end

    context 'when FreeBSD RELEASE' do
      let(:value) { '12.1-RELEASE-p3' }

      it 'calls Facter::Resolvers::Freebsd::FreebsdVersion' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Freebsd::FreebsdVersion).to have_received(:resolve).with(:installed_userland)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: { 'full' => value,
                                                                                   'major' => '12',
                                                                                   'minor' => '1',
                                                                                   'branch' => 'RELEASE-p3',
                                                                                   'patchlevel' => '3' }),
                          an_object_having_attributes(name: 'operatingsystemmajrelease', value: '12',
                                                      type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
      end
    end

    context 'when FreeBSD STABLE' do
      let(:value) { '12.1-STABLE' }

      it 'calls Facter::Resolvers::Freebsd::FreebsdVersion' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Freebsd::FreebsdVersion).to have_received(:resolve).with(:installed_userland)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: { 'full' => value,
                                                                                   'major' => '12',
                                                                                   'minor' => '1',
                                                                                   'branch' => 'STABLE' }),
                          an_object_having_attributes(name: 'operatingsystemmajrelease', value: '12',
                                                      type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
      end
    end

    context 'when FreeBSD CURRENT' do
      let(:value) { '13-CURRENT' }

      it 'calls Facter::Resolvers::Freebsd::FreebsdVersion' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Freebsd::FreebsdVersion).to have_received(:resolve).with(:installed_userland)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: { 'full' => value,
                                                                                   'major' => '13',
                                                                                   'branch' => 'CURRENT' }),
                          an_object_having_attributes(name: 'operatingsystemmajrelease', value: '13',
                                                      type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
      end
    end
  end
end
