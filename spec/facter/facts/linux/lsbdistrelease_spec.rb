# frozen_string_literal: true

describe Facts::Linux::Lsbdistrelease do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Lsbdistrelease.new }

    context 'when lsb-release is installed' do
      before do
        allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:release).and_return(value)
      end

      context 'when version_id is retrieved successful' do
        context 'when version consists of only major' do
          let(:value) { '10' }
          let(:value_final) { { 'full' => '10', 'major' => '10', 'minor' => nil } }

          it 'calls Facter::Resolvers::LsbRelease with :name' do
            fact.call_the_resolver
            expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:release)
          end

          it 'returns release fact' do
            expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
              contain_exactly(an_object_having_attributes(name: 'lsbdistrelease', value: value, type: :legacy),
                              an_object_having_attributes(name: 'lsbmajdistrelease',
                                                          value: value_final['major'], type: :legacy),
                              an_object_having_attributes(name: 'lsbminordistrelease',
                                                          value: value_final['minor'], type: :legacy))
          end
        end

        context 'when versin consists of both major and minor' do
          let(:value) { '10.08' }
          let(:value_final) { { 'full' => '10.08', 'major' => '10', 'minor' => '08' } }

          it 'calls Facter::Resolvers::LsbRelease with :name' do
            fact.call_the_resolver
            expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:release)
          end

          it 'returns release fact' do
            expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
              contain_exactly(an_object_having_attributes(name: 'lsbdistrelease', value: value, type: :legacy),
                              an_object_having_attributes(name: 'lsbmajdistrelease',
                                                          value: value_final['major'], type: :legacy),
                              an_object_having_attributes(name: 'lsbminordistrelease',
                                                          value: value_final['minor'], type: :legacy))
          end
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
