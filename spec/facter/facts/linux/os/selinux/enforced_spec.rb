# frozen_string_literal: true

describe Facts::Linux::Os::Selinux::Enforced do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Os::Selinux::Enforced.new }

    let(:enforced) { false }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enforced).and_return(enforced)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:enforced)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux.enforced', value: enforced),
                        an_object_having_attributes(name: 'selinux_enforced', value: enforced, type: :legacy))
    end
  end
end
