# frozen_string_literal: true

# fozen_string_literal: true

describe Facts::Macosx::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Release.new }

    let(:value) { '10.9' }
    let(:value_final) {  { 'full' => '10.9', 'major' => '10', 'minor' => '9' } }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return('10.9')
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver

      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.release', value: value_final),
                        an_object_having_attributes(name: 'operatingsystemmajrelease', value: value_final['major'],
                                                    type: :legacy),
                        an_object_having_attributes(name: 'operatingsystemrelease', value: value_final['full'],
                                                    type: :legacy))
    end
  end
end
