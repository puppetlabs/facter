# frozen_string_literal: true

describe Facts::Sles::Augeas::Version do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Augeas::Version.new }

    let(:version) { '1.12.0' }

    before do
      allow(Facter::Resolvers::Augeas).to \
        receive(:resolve).with(:augeas_version).and_return(version)
    end

    it 'calls Facter::Resolvers::Augeas' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Augeas).to have_received(:resolve).with(:augeas_version)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'augeas.version', value: version),
                        an_object_having_attributes(name: 'augeasversion', value: version, type: :legacy))
    end
  end
end
