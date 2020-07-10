# frozen_string_literal: true

describe Facts::Macosx::Os::Macosx::Build do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Macosx::Build.new }

    let(:version) { '10.9.8' }

    before do
      allow(Facter::Resolvers::SwVers).to \
        receive(:resolve).with(:buildversion).and_return(version)
    end

    it 'calls Facter::Resolvers::SwVers' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:buildversion)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.macosx.build', value: version),
                        an_object_having_attributes(name: 'macosx_buildversion', value: version, type: :legacy))
    end
  end
end
