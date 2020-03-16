# frozen_string_literal: true

describe Facts::Debian::Os::Selinux::ConfigMode do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Selinux::ConfigMode.new }

    let(:config_mode) { 'enabled' }

    before do
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:config_mode).and_return(config_mode)
    end

    it 'calls Facter::Resolvers::SELinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SELinux).to have_received(:resolve).with(:config_mode)
    end

    it 'returns architecture fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.selinux.config_mode', value: config_mode),
                        an_object_having_attributes(name: 'selinux_config_mode', value: config_mode, type: :legacy))
    end
  end
end
