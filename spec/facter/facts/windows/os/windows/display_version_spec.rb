# frozen_string_literal: true

describe Facts::Windows::Os::Windows::DisplayVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Os::Windows::DisplayVersion.new }

    let(:value) { '1607' }

    before do
      allow(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:display_version).and_return(value)
    end

    it 'calls Facter::Resolvers::ProductRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::ProductRelease).to have_received(:resolve).with(:display_version)
    end

    it 'returns os release id fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.windows.display_version', value: value),
                        an_object_having_attributes(name: 'windows_display_version', value: value, type: :legacy))
    end
  end
end
