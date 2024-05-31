# frozen_string_literal: true

describe Facter::Resolvers::RedHatRelease do
  subject(:redhat_release) { Facter::Resolvers::RedHatRelease }

  after do
    Facter::Resolvers::RedHatRelease.invalidate_cache
  end

  context 'when redhat-release has codename' do
    {
      fedora: {
        release_file_content: "Fedora release 32 (Thirty Two)\n",
        id: 'rhel',
        name: 'Fedora',
        version: '32',
        codename: 'Thirty Two',
        description: 'Fedora release 32 (Thirty Two)',
        distributor_id: 'Fedora'

      },
      el: {
        release_file_content: "Red Hat Enterprise Linux release 8.0 (Ootpa)\n",
        id: 'rhel',
        name: 'RedHat',
        version: '8.0',
        codename: 'Ootpa',
        description: 'Red Hat Enterprise Linux release 8.0 (Ootpa)',
        distributor_id: 'RedHatEnterprise'
      },
      el_server: {
        release_file_content: "Red Hat Enterprise Linux Server release 5.10 (Tikanga)\n",
        id: 'rhel',
        name: 'RedHat',
        version: '5.10',
        codename: 'Tikanga',
        description: 'Red Hat Enterprise Linux Server release 5.10 (Tikanga)',
        distributor_id: 'RedHatEnterpriseServer'
      },
      centos: {
        release_file_content: "CentOS Linux release 7.2.1511 (Core)\n",
        id: 'rhel',
        name: 'CentOS',
        version: '7.2.1511',
        codename: 'Core',
        description: 'CentOS Linux release 7.2.1511 (Core)',
        distributor_id: 'CentOS'
      }
    }.each_pair do |platform, data|
      context "when #{platform.capitalize}" do
        before do
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with('/etc/redhat-release', nil)
            .and_return(data[:release_file_content])
        end

        it 'returns os NAME' do
          expect(redhat_release.resolve(:name)).to eq(data[:name])
        end

        it 'returns os ID' do
          expect(redhat_release.resolve(:id)).to eq(data[:id])
        end

        it 'returns os VERSION_ID' do
          expect(redhat_release.resolve(:version)).to eq(data[:version])
        end

        it 'returns os VERSION_CODENAME' do
          expect(redhat_release.resolve(:codename)).to eq(data[:codename])
        end

        it 'returns os DESCRIPTION' do
          expect(redhat_release.resolve(:description)).to eq(data[:description])
        end

        it 'returns os DISTRIBUTOR_ID' do
          expect(redhat_release.resolve(:distributor_id)).to eq(data[:distributor_id])
        end
      end
    end
  end

  context 'when redhat-relase does not have codename' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/redhat-release', nil)
        .and_return("Oracle VM server release 3.4.4\n")
    end

    it 'returns os NAME' do
      expect(redhat_release.resolve(:name)).to eq('OracleVM')
    end

    it 'returns os VERSION_ID' do
      expect(redhat_release.resolve(:version)).to eq('3.4.4')
    end

    it 'returns os VERSION_CODENAME' do
      expect(redhat_release.resolve(:codename)).to be_nil
    end
  end
end
