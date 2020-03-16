# frozen_string_literal: true

describe Facts::Debian::Os::Family do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Family.new }

    let(:value) { 'Debian' }

    context 'when OsRelease resolver returns id_like' do
      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id_like).and_return(value)
      end

      it 'calls Facter::Resolvers::OsRelease' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:id_like)
      end

      it 'returns os family fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.family', value: value),
                          an_object_having_attributes(name: 'osfamily', value: value, type: :legacy))
      end
    end

    context 'when OsRelease resolver does not return id_like and fact has to call OsRelease resolver twice' do
      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id_like).and_return(nil)
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id).and_return(value)
      end

      it 'calls Facter::Resolvers::OsRelease' do
        expect(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id_like)
        expect(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id)
        fact.call_the_resolver
      end

      it 'returns os family fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.family', value: value),
                          an_object_having_attributes(name: 'osfamily', value: value, type: :legacy))
      end
    end
  end
end
