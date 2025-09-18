# frozen_string_literal: true

describe Facter::Util::Facts::WindowsReleaseFinder do
  let(:input) { { consumerrel: cons, description: desc, kernel_version: k_version, version: version } }

  describe '#find windows release when version nil' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) {}
    let(:version) { nil }

    it 'returns nil' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to be(nil)
    end
  end

  describe '#find windows release when version is 10' do
    let(:cons) { true }
    let(:desc) {}
    let(:k_version) { '10.0.10240' }
    let(:version) { '10.0' }

    it 'returns 10' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('10')
    end
  end

  describe '#find windows release when version is 11' do
    let(:cons) { true }
    let(:desc) {}
    let(:k_version) { '10.0.22000' }
    let(:version) { '10.0' }

    it 'returns 11' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('11')
    end
  end

  describe '#find windows release when version is 2025' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) { '10.0.26100' }
    let(:version) { '10.0' }

    it 'returns 2025' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2025')
    end
  end

  describe '#find windows release when version is 2022' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) { '10.0.20348' }
    let(:version) { '10.0' }

    it 'returns 2022' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2022')
    end
  end

  describe '#find windows release when version is 2019' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) { '10.0.17763' }
    let(:version) { '10.0' }

    it 'returns 2019' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2019')
    end
  end

  describe '#find windows release when version is 2016' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) { '10.0.176' }
    let(:version) { '10.0' }

    it 'returns 2016' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2016')
    end
  end

  describe '#find windows release when version is 8.1' do
    let(:cons) { true }
    let(:desc) {}
    let(:k_version) {}
    let(:version) { '6.3' }

    it 'returns 8.1' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('8.1')
    end
  end

  describe '#find windows release when version is 2012 R2' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) {}
    let(:version) { '6.3' }

    it 'returns 2012 R2' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2012 R2')
    end
  end

  describe '#find windows release when version is XP' do
    let(:cons) { true }
    let(:desc) {}
    let(:k_version) {}
    let(:version) { '5.2' }

    it 'returns XP' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('XP')
    end
  end

  describe '#find windows release when version is 2003' do
    let(:cons) { false }
    let(:desc) {}
    let(:k_version) {}
    let(:version) { '5.2' }

    it 'returns 2003' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2003')
    end
  end

  describe '#find windows release when version is 2003 R2' do
    let(:cons) { false }
    let(:desc) { 'R2' }
    let(:k_version) {}
    let(:version) { '5.2' }

    it 'returns 2003 R2' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('2003 R2')
    end
  end

  describe '#find windows release when version is 4.2' do
    let(:cons) { false }
    let(:desc) { 'R2' }
    let(:k_version) {}
    let(:version) { '4.2' }

    it 'returns 4.2' do
      expect(Facter::Util::Facts::WindowsReleaseFinder.find_release(input)).to eql('4.2')
    end
  end
end
