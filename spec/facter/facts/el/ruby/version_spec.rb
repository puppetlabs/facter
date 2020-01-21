# frozen_string_literal: true

describe 'El RubyVersion' do
  context '#call_the_resolver' do
    let(:value) { '2.5.7' }
    subject(:fact) { Facter::El::RubyVersion.new }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:version).and_return(value)
    end

    it 'calls Facter::Resolvers::Ruby' do
      expect(Facter::Resolvers::Ruby).to receive(:resolve).with(:version)
      fact.call_the_resolver
    end

    it 'returns ruby version fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'ruby.version', value: value),
                        an_object_having_attributes(name: 'rubyversion', value: value, type: :legacy))
    end
  end
end
