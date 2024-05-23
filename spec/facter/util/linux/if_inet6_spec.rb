# frozen_string_literal: true

describe Facter::Util::Linux::IfInet6 do
  subject(:if_inet6) { Facter::Util::Linux::IfInet6 }

  let(:simple) do
    {
      'ens160' => { 'fe80::250:56ff:fe9a:8481' => ['permanent'] },
      'lo' => { '::1' => ['permanent'] }
    }
  end
  let(:complex) do
    {
      'temporary' => { '2001:db8::1' => ['temporary'] },
      'noad' => { '2001:db8::2' => ['noad'] },
      'optimistic' => { '2001:db8::3' => ['optimistic'] },
      'dadfailed' => { '2001:db8::4' => ['dadfailed'] },
      'homeaddress' => { '2001:db8::5' => ['homeaddress'] },
      'deprecated' => { '2001:db8::6' => ['deprecated'] },
      'tentative' => { '2001:db8::7' => ['tentative'] },
      'permanent' => { '2001:db8::8' => ['permanent'] },
      'everything' => { '2001:db8::9' => %w[temporary noad optimistic dadfailed
                                            homeaddress deprecated tentative permanent] },
      'lo' => { '::1' => ['permanent'] }
    }
  end

  describe '#read_flags' do
    context 'when only ipv6 link-local and lo ipv6 present' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/proc/net/if_inet6').and_return(true)
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/proc/net/if_inet6', nil).and_return(load_fixture('proc_net_if_inet6').read)
      end

      it { expect(if_inet6.read_flags).to eq(simple) }
    end

    context 'when multiple IPv6 addresses present with different flags' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/proc/net/if_inet6').and_return(true)
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/proc/net/if_inet6', nil).and_return(load_fixture('proc_net_if_inet6_complex').read)
      end

      it { expect(if_inet6.read_flags).to eq(complex) }
    end
  end
end
