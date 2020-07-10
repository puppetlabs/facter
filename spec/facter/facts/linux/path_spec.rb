# frozen_string_literal: true

describe Facts::Linux::Path do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Path.new }

    let(:value) { '/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/java6/jre/bin:/usr/java6/bin' }

    before do
      allow(Facter::Resolvers::Path).to \
        receive(:resolve).with(:path).and_return(value)
    end

    it 'calls Facter::Resolvers::Path' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Path).to have_received(:resolve).with(:path)
    end

    it 'returns path fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'path', value: value)
    end
  end
end
