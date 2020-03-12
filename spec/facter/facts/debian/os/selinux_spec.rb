# frozen_string_literal: true

describe Facts::Debian::Os::Selinux do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Selinux.new }

    let(:value) { 'selinux' }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enabled).and_return(value)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:enabled)
    end

    it 'returns selinux fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux', value: { 'enabled' => value }),
                        an_object_having_attributes(name: 'selinux', value: value, type: :legacy))
    end
  end
end
