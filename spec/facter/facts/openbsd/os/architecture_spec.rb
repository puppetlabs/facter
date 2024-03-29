# frozen_string_literal: true

describe Facts::Openbsd::Os::Architecture do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::Os::Architecture.new }

    let(:value) { 'amd64' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return(value)
    end

    it 'calls Facter::Resolvers::Uname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:machine)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.architecture', value: value),
                        an_object_having_attributes(name: 'architecture', value: value, type: :legacy))
    end
  end
end
