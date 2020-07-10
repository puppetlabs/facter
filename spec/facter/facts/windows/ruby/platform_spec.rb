# frozen_string_literal: true

describe Facts::Windows::Ruby::Platform do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Ruby::Platform.new }

    let(:value) { 'x64-mingw32' }

    before do
      allow(Facter::Resolvers::Ruby).to receive(:resolve).with(:platform).and_return(value)
    end

    it 'calls Facter::Resolvers::Ruby' do
      expect(Facter::Resolvers::Ruby).to receive(:resolve).with(:platform)
      fact.call_the_resolver
    end

    it 'returns ruby platform fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'ruby.platform', value: value),
                        an_object_having_attributes(name: 'rubyplatform', value: value, type: :legacy))
    end
  end
end
