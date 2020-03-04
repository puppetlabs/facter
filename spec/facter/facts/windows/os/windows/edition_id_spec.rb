# frozen_string_literal: true

describe Facts::Windows::Os::Windows::EditionId do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Os::Windows::EditionId.new }

    let(:value) { 'ServerStandard' }

    before do
      allow(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:edition_id).and_return(value)
    end

    it 'calls Facter::Resolvers::ProductRelease' do
      expect(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:edition_id)
      fact.call_the_resolver
    end

    it 'returns os edition id fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.windows.edition_id', value: value),
                        an_object_having_attributes(name: 'windows_edition_id', value: value, type: :legacy))
    end
  end
end
