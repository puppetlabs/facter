# frozen_string_literal: true

describe Facts::Macosx::Os::Hardware do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Hardware.new }

    let(:value) { 'value' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return(value)
    end

    it 'returns augeas fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.hardware', value: value),
                        an_object_having_attributes(name: 'hardwaremodel', value: value, type: :legacy))
    end
  end
end
