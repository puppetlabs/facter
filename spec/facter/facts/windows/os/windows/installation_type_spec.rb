# frozen_string_literal: true

describe 'Windows OsWindowsInstallationType' do
  context '#call_the_resolver' do
    let(:value) { 'Server' }
    subject(:fact) { Facter::Windows::OsWindowsInstallationType.new }

    before do
      allow(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:installation_type).and_return(value)
    end

    it 'calls Facter::Resolvers::ProductRelease' do
      expect(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:installation_type)
      fact.call_the_resolver
    end

    it 'returns os installation type fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.windows.installation_type', value: value),
                        an_object_having_attributes(name: 'windows_installation_type', value: value, type: :legacy))
    end
  end
end
