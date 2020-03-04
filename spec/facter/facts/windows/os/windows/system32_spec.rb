# frozen_string_literal: true

describe Facts::Windows::Os::Windows::System32 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Os::Windows::System32.new }

    let(:value) { 'C:\Windows\system32' }

    before do
      allow(Facter::Resolvers::System32).to receive(:resolve).with(:system32).and_return(value)
    end

    it 'calls Facter::Resolvers::System32' do
      expect(Facter::Resolvers::System32).to receive(:resolve).with(:system32)
      fact.call_the_resolver
    end

    it 'returns system32 path' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.windows.system32', value: value),
                        an_object_having_attributes(name: 'system32', value: value, type: :legacy))
    end
  end
end
