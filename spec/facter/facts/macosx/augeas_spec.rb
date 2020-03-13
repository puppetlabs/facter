# frozen_string_literal: true

describe Facts::Macosx::Augeas do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Augeas.new }

    let(:value) { '1.12.0' }

    before do
      allow(Facter::Resolvers::Augeas).to receive(:resolve).with(:augeas_version).and_return(value)
    end

    it 'calls Facter::Resolvers::Augeas' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Augeas).to have_received(:resolve).with(:augeas_version)
    end

    it 'returns augeas fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'augeas.version', value: value),
                        an_object_having_attributes(name: 'augeasversion', value: value, type: :legacy))
    end
  end
end
