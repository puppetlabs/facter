# frozen_string_literal: true

describe Facts::Ubuntu::Lsbdistrelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Ubuntu::Lsbdistrelease.new }

    context 'when lsb-release is installed' do
      before do
        allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:release).and_return(value)
      end

      context 'when version_id is retrieved successful' do
        let(:value) { '18.04' }
        let(:value_final) { { 'full' => '18.04', 'major' => '18.04', 'minor' => nil } }

        it 'returns release fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
            contain_exactly(an_object_having_attributes(name: 'lsbdistrelease', value: value, type: :legacy),
                            an_object_having_attributes(name: 'lsbmajdistrelease',
                                                        value: value_final['major'], type: :legacy),
                            an_object_having_attributes(name: 'lsbminordistrelease',
                                                        value: value_final['minor'], type: :legacy))
        end
      end

      context 'when lsb-release is not installed' do
        let(:value) { nil }

        it 'returns release fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'lsbdistrelease', value: value, type: :legacy)
        end
      end
    end
  end
end
