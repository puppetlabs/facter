test_name "Facts should resolve as expected in Ubuntu 12.04, 14.04, and 14.10"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in Ubuntu 12.04, 14.04, and 14.10
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /ubuntu-precise|ubuntu-trusty|ubuntu-utopic/

agents.each do |agent|
  if agent['platform'] =~ /ubuntu-precise/
    os_name    = 'precise'
    os_version = '12.04'
    os_kernel  = '3.2'
  elsif agent['platform'] =~ /ubuntu-trusty/
    os_name    = 'trusty'
    os_version = '14.04'
    os_kernel  = '3.13'
  else
    os_name    = 'utopic'
    os_version = '14.10'
    os_kernel  = '3.16'
  end

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
                  'os.distro.codename'      => os_name,
                  'os.distro.description'   => /Ubuntu #{os_version}( LTS)?/,
                  'os.distro.id'            => 'Ubuntu',
                  'os.distro.release.full'  => os_version,
                  'os.distro.release.major' => os_version,
                  'os.family'               => 'Debian',
                  'os.hardware'             => os_hardware,
                  'os.name'                 => 'Ubuntu',
                  'os.release.full'         => os_version,
                  'os.release.major'        => os_version,
                }

  expected_os.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Processors fact resolves with reasonable values"
  expected_processors = {
                          'processors.count'         => /[1-9]/,
                          'processors.physicalcount' => /[1-9]/,
                          'processors.isa'           => os_hardware,
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
  expected_kernel = {
                      'kernel'           => 'Linux',
                      'kernelrelease'    => os_kernel,
                      'kernelversion'    => os_kernel,
                      'kernelmajversion' => os_kernel
                    }

  expected_kernel.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end
end
