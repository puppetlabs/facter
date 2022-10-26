# frozen_string_literal: true

describe Facts::Openbsd::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::Os::Release.new }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(value)
    end

    context 'when OpenBSD RELEASE' do
      let(:value) { '7.2' }

      it 'calls Facter::Resolvers::Uname' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Uname).to have_received(:resolve).with(:kernelrelease)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: { 'full' => value,
                                                                                   'major' => '7',
                                                                                   'minor' => '2' }),
                          an_object_having_attributes(name: 'operatingsystemmajrelease', value: '7',
                                                      type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease', value: value, type: :legacy))
      end
    end
  end
end
