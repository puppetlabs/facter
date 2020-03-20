# frozen_string_literal: true

describe Facts::Aix::Os::Architecture do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Os::Architecture.new }

    let(:value) { 'x86_64' }

    before do
      allow(Facter::Resolvers::Architecture).to receive(:resolve).with(:architecture).and_return(value)
    end

    it 'calls Facter::Resolvers::Architecture' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Architecture).to have_received(:resolve).with(:architecture)
    end

    it 'returns os architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.architecture', value: value),
                        an_object_having_attributes(name: 'architecture', value: value, type: :legacy))
    end
  end
end
