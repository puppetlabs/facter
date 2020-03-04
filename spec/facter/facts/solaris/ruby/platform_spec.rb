# frozen_string_literal: true

describe Facts::Solaris::Ruby::Platform do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Ruby::Platform.new }

    let(:value) { 'x86_64-linux' }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:platform).and_return(value)
    end

    it 'calls Facter::Resolvers::Ruby' do
      expect(Facter::Resolvers::Ruby).to receive(:resolve).with(:platform).and_return(value)
      fact.call_the_resolver
    end

    it 'return ruby.platform fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'ruby.platform', value: value)
    end
  end
end
