test_name "Facts should resolve as expected in Debian 6 and 7"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in Debian 6 and 7.
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /debian-squeeze|debian-wheezy/

agents.each do |agent|
  os_version = agent['platform'] =~ /squeeze/ ? '6' : '7'
  if agent['platform'] =~ /x86_64/
    os_arch     = 'amd64'
    os_hardware = 'x86_64'
  else
    os_arch     = 'i386'
    os_hardware = 'i686'
  end

  step "Ensure the OS fact resolves as expected"
  expected_os = {
                  'os.architecture'         => os_arch,
                  'os.distro.codename'      => os_version == '6' ? 'squeeze' : 'wheezy',
                  'os.distro.description'   => /Debian GNU\/Linux #{os_version}\.\d/,
                  'os.distro.id'            => 'Debian',
                  'os.distro.release.full'  => /#{os_version}\.\d/,
                  'os.distro.release.major' => os_version,
                  'os.distro.release.minor' => /\d/,
                  'os.family'               => 'Debian',
                  'os.hardware'             => os_hardware,
                  'os.name'                 => 'Debian',
                  'os.release.full'         => /#{os_version}\.\d/,
                  'os.release.major'        => os_version,
                  'os.release.minor'        => /\d/,
                }

  expected_os.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Processors fact resolves with reasonable values"
  expected_processors = {
                          'processors.count'         => /[1-9]/,
                          'processors.physicalcount' => /[1-9]/,
                          'processors.isa'           => /unknown|#{os_hardware}/,
                          'processors.models'        => /"Intel\(R\).*"/
                        }

  expected_processors.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Networking fact resolves with reasonable values for at least one interface"

  expected_networking = {
                          "networking.dhcp"     => /10\.\d+\.\d+\.\d+/,
                          "networking.ip"       => /10\.\d+\.\d+\.\d+/,
                          "networking.ip6"      => /[a-z0-9]+:+/,
                          "networking.mac"      => /[a-z0-9]{2}:/,
                          "networking.mtu"      => /\d+/,
                          "networking.netmask"  => /\d+\.\d+\.\d+\.\d+/,
                          "networking.netmask6" => /[a-z0-9]+:/,
                          "networking.network"  => /10\.\d+\.\d+\.\d+/,
                          "networking.network6" => /([a-z0-9]+)?:([a-z0-9]+)?/
                        }

  expected_networking.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the identity fact resolves as expected"
  expected_identity = {
                        'identity.gid'   => '0',
                        'identity.group' => 'root',
                        'identity.uid'   => '0',
                        'identity.user'  => 'root'
                      }

  expected_identity.each do |fact, value|
    assert_equal(value, fact_on(agent, fact))
  end

  step "Ensure the kernel fact resolves as expected"
  kernel_version = os_version == '7' ? '3.2' : '2.6'

  expected_kernel = {
                      'kernel'           => 'Linux',
                      'kernelrelease'    => kernel_version,
                      'kernelversion'    => kernel_version,
                      'kernelmajversion' => kernel_version
                    }

  expected_kernel.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end
end
