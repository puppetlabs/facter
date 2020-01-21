# frozen_string_literal: true

describe 'Solaris RubySitedir' do
  context '#call_the_resolver' do
    let(:value) { '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.5.0' }
    subject(:fact) { Facter::Solaris::RubySitedir.new }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:sitedir).and_return(value)
    end

    it 'calls Facter::Resolvers::Ruby' do
      expect(Facter::Resolvers::Ruby).to receive(:resolve).with(:sitedir).and_return(value)
      fact.call_the_resolver
    end

    it 'return ruby sitedir fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'ruby.sitedir', value: value)
    end
  end
end
