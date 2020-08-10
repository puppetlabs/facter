# frozen_string_literal: true

describe Facts::Freebsd::Ruby::Platform do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Ruby::Platform.new }

    let(:value) { 'amd64-freebsd12' }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:platform).and_return(value)
    end

    it 'calls Facter::Resolvers::Ruby' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Ruby).to have_received(:resolve).with(:platform)
    end

    it 'return ruby.platform fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'ruby.platform', value: value),
                        an_object_having_attributes(name: 'rubyplatform', value: value, type: :legacy))
    end
  end
end
