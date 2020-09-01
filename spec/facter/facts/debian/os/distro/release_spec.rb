# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Release.new }

    shared_examples 'returns distro release fact' do
      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: fact_value),
                          an_object_having_attributes(name: 'lsbdistrelease', value: fact_value['full'], type: :legacy),
                          an_object_having_attributes(name: 'lsbmajdistrelease', value: fact_value['major'],
                                                      type: :legacy),
                          an_object_having_attributes(name: 'lsbminordistrelease', value: fact_value['minor'],
                                                      type: :legacy))
      end
    end

    before do
      allow(Facter::Resolvers::DebianVersion).to receive(:resolve).with(:version).and_return(os_release_value)
    end

    context 'when version_id is retrieved successfully' do
      let(:os_release_value) { '10.02' }
      let(:fact_value) { { 'full' => '10.02', 'major' => '10', 'minor' => '2' } }

      it 'calls Facter::Resolvers::DebianVersion' do
        fact.call_the_resolver
        expect(Facter::Resolvers::DebianVersion).to have_received(:resolve).with(:version)
      end

      it_behaves_like 'returns distro release fact'
    end

    context 'when version_id could not be retrieve' do
      let(:os_release_value) { nil }
      let(:fact_value) { nil }

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.release', value: fact_value)
      end
    end

    context 'when version has no minor' do
      let(:os_release_value) { 'bullseye/sid' }
      let(:fact_value) { { 'full' => 'bullseye/sid', 'major' => 'bullseye/sid' } }

      it_behaves_like 'returns distro release fact'
    end
  end
end
