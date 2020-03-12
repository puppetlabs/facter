# frozen_string_literal: true

describe Facts::El::Os::Selinux do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Os::Selinux.new }

    let(:selinux) { false }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enabled).and_return(selinux)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:enabled)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux', value: { 'enabled' => selinux }),
                        an_object_having_attributes(name: 'selinux', value: selinux, type: :legacy))
    end
  end
end
