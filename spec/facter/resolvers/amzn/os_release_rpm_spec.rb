# frozen_string_literal: true

describe Facter::Resolvers::Amzn::OsReleaseRpm do
  subject(:os_release_resolver) { Facter::Resolvers::Amzn::OsReleaseRpm }

  let(:log_spy) { Facter::Log }

  before do
    os_release_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with("rpm -q --qf '%{NAME}\\n%{VERSION}\\n%{RELEASE}\\n%{VENDOR}' -f /etc/os-release", { logger: log_spy })
      .and_return(os_release_content)
  end

  after do
    os_release_resolver.invalidate_cache
  end

  context 'when on AmazonLinux 2023' do
    let(:os_release_content) { "system-release\n2023.2.20231113\n1.amzn2023\nAmazon Linux" }

    it 'returns os release package version' do
      expect(os_release_resolver.resolve(:version)).to eq('2023.2.20231113')
    end

    it 'returns os release package release' do
      expect(os_release_resolver.resolve(:release)).to eq('1.amzn2023')
    end

    it 'returns os release package vendor' do
      expect(os_release_resolver.resolve(:vendor)).to eq('Amazon Linux')
    end
  end

  context 'when on AmazonLinux 2' do
    let(:os_release_content) { "system-release\n2\n16.amzn2\nAmazon Linux" }

    it 'returns os release package version' do
      expect(os_release_resolver.resolve(:version)).to eq('2')
    end

    it 'returns os release package release' do
      expect(os_release_resolver.resolve(:release)).to eq('16.amzn2')
    end
  end

  context 'when on os-release file missing' do
    let(:os_release_content) { '' }

    it 'returns nil VERSION' do
      expect(os_release_resolver.resolve(:version)).to be_nil
    end
  end
end
