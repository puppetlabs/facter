test_name "Facts should resolve as expected in Mac OS X 10.9 and 10.10"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in Mac OS X 10.9 and 10.10
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /osx-mavericks|osx-yosemite/

agents.each do |agent|
  if agent['platform'] =~ /osx-mavericks/
    os_version = '10.9'
    kernel_major = '13'
  else
    os_version = '10.10'
    kernel_major = '14'
  end

  step "Ensure the OS fact resolves as expected"

  expected_os = {
                  'os.architecture'         => 'x86_64',
                  'os.family'               => 'Darwin',
                  'os.hardware'             => 'x86_64',
                  'os.name'                 => 'Darwin',
                  'os.macosx.build'         => /#{kernel_major}[A-Z]\d{2,4}\w?/,
                  'os.macosx.product'       => 'Mac OS X',
                  'os.macosx.version.full'  => /#{os_version}\.\d/,
                  'os.macosx.version.major' => os_version,
                  'os.macosx.version.minor' => /\d/,
                  'os.release.full'         => /#{kernel_major}\.\d\.\d/,
                  'os.release.major'        => kernel_major,
                  'os.release.minor'        => /\d/,
                }

  expected_os.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Processors fact resolves with reasonable values"

  expected_processors = {
                          'processors.count'         => /[1-9]/,
                          'processors.physicalcount' => /[1-9]/,
                          'processors.isa'           => 'i386',
                          'processors.models'        => /"Intel\(R\).*"/
                        }

  expected_processors.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Networking fact resolves with reasonable values for at least one interface"

  expected_networking = {
                          "networking.dhcp"     => /10\.\d+\.\d+\.\d+/,
                          "networking.ip"       => /10\.\d+\.\d+\.\d+/,
                          "networking.ip6"      => /[a-f0-9]+:+/,
                          "networking.mac"      => /[a-f0-9]{2}:/,
                          "networking.mtu"      => /\d+/,
                          "networking.netmask"  => /\d+\.\d+\.\d+\.\d+/,
                          "networking.netmask6" => /[a-f0-9]+:/,
                          "networking.network"  => /10\.\d+\.\d+\.\d+/,
                          "networking.network6" => /([a-f0-9]+)?:([a-f0-9]+)?/
                        }

  expected_networking.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the identity fact resolves as expected"
  expected_identity = {
                        'identity.gid'   => '0',
                        'identity.group' => 'wheel',
                        'identity.uid'   => '0',
                        'identity.user'  => 'root'
                      }

  expected_identity.each do |fact, value|
    assert_equal(value, fact_on(agent, fact))
  end

  step "Ensure the kernel fact resolves as expected"

  expected_kernel = {
                      'kernel'           => 'Darwin',
                      'kernelrelease'    => /#{kernel_major}\.\d\.\d/,
                      'kernelversion'    => /#{kernel_major}\.\d\.\d/,
                      'kernelmajversion' => /#{kernel_major}\.\d/
                    }

  expected_kernel.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end
end
