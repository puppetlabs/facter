# frozen_string_literal: true

describe Facts::Aix::Ruby::Sitedir do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Ruby::Sitedir.new }

    let(:value) { '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.5.0' }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:sitedir).and_return(value)
    end

    it 'calls Facter::Resolvers::Ruby' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Ruby).to have_received(:resolve).with(:sitedir)
    end

    it 'returns ruby site dir fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'ruby.sitedir', value: value),
                        an_object_having_attributes(name: 'rubysitedir', value: value, type: :legacy))
    end
  end
end
