# frozen_string_literal: true

describe Facts::Linux::Os::Architecture do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Os::Architecture.new }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return(value)
    end

    context 'when os is 64-bit' do
      let(:value) { 'x86_64' }

      it 'calls Facter::Resolvers::Uname' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:machine)
      end

      it 'returns architecture fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.architecture', value: value),
                          an_object_having_attributes(name: 'architecture', value: value, type: :legacy))
      end
    end

    context 'when os is 32-bit' do
      let(:value) { 'i686' }
      let(:fact_value) { 'i386' }

      it 'calls Facter::Resolvers::Uname' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:machine)
      end

      it 'returns architecture fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.architecture', value: fact_value),
                          an_object_having_attributes(name: 'architecture', value: fact_value, type: :legacy))
      end
    end
  end
end
