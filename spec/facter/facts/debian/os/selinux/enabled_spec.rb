# frozen_string_literal: true

describe Facts::Debian::Os::Selinux::Enabled do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Selinux::Enabled.new }

    let(:enabled) { true }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enabled).and_return(enabled)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:enabled)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux.enabled', value: enabled),
                        an_object_having_attributes(name: 'selinux', value: enabled, type: :legacy))
    end
  end
end
