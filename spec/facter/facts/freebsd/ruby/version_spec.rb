# frozen_string_literal: true

describe Facts::Freebsd::Ruby::Version do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Ruby::Version.new }

    let(:value) { '2.5.9' }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:version).and_return(value)
    end

    it 'returns ruby version fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'ruby.version', value: value),
                             an_object_having_attributes(name: 'rubyversion', value: value, type: :legacy))
    end
  end
end
