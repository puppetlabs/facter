# frozen_string_literal: true

describe Facts::Macosx::Ruby::Platform do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Ruby::Platform.new }

    let(:value) { 'x86_64-linux' }

    before do
      allow(Facter::Resolvers::Ruby).to \
        receive(:resolve).with(:platform).and_return(value)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'ruby.platform', value: value),
                        an_object_having_attributes(name: 'rubyplatform', value: value, type: :legacy))
    end
  end
end
