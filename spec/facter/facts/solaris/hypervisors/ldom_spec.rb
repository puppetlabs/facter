# frozen_string_literal: true

describe Facts::Solaris::Hypervisors::Ldom do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Hypervisors::Ldom.new }

    before do
      allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve)
    end

    context 'when Ldom resolver returns values' do
      let(:value) do
        {
          'chassis_serial' => 'AK00358110',
          'control_domain' => 'opdx-a0-sun2',
          'domain_name' => 'sol11-9',
          'domain_uuid' => 'd7a3a4df-ce8c-47a9-b396-cb5a5f30c0b2',
          'role_control' => 'false',
          'role_io' => 'false',
          'role_root' => 'false',
          'role_service' => 'false'
        }
      end

      before do
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:chassis_serial).and_return('AK00358110')
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:control_domain).and_return('opdx-a0-sun2')
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:domain_name).and_return('sol11-9')
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return('false')
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_io).and_return('false')
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_root).and_return('false')
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_service).and_return('false')
        allow(Facter::Resolvers::Solaris::Ldom)
          .to receive(:resolve)
          .with(:domain_uuid)
          .and_return('d7a3a4df-ce8c-47a9-b396-cb5a5f30c0b2')
      end

      it 'returns virtual fact as physical' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.ldom', value: value)
      end
    end

    context 'when ldom resolver returns nil' do
      before do
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:chassis_serial).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:control_domain).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:domain_name).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_io).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_root).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_service).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:domain_uuid).and_return(nil)
      end

      context 'when role_control is false' do
        let(:value) do
          {
            'chassis_serial' => nil,
            'control_domain' => nil,
            'domain_name' => nil,
            'domain_uuid' => nil,
            'role_control' => nil,
            'role_io' => nil,
            'role_root' => nil,
            'role_service' => nil
          }
        end

        it 'returns virtual fact as physical' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'hypervisors.ldom', value: value)
        end
      end
    end
  end
end
