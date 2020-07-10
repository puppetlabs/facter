# frozen_string_literal: true

describe Facts::Windows::Os::Windows::ReleaseId do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Os::Windows::ReleaseId.new }

    let(:value) { '1607' }

    before do
      allow(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:release_id).and_return(value)
    end

    it 'calls Facter::Resolvers::ProductRelease' do
      expect(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:release_id)
      fact.call_the_resolver
    end

    it 'returns os release id fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.windows.release_id', value: value),
                        an_object_having_attributes(name: 'windows_release_id', value: value, type: :legacy))
    end
  end
end
