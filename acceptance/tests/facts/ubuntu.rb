test_name "C15288: Facts should resolve as expected on Ubuntu" do
  tag 'risk:high'

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in all supported Ubuntu versions.
#
# Facts tested: os, processors, networking, identity, kernel
#

  confine :to, :platform => /ubuntu/

  agents.each do |agent|
    if agent['platform'] =~ /ubuntu-10.04/
      os_name    = 'lucid'
      os_version = '10.04'
      os_kernel  = /2.\d+/
    elsif agent['platform'] =~ /ubuntu-12.04/
      os_name    = 'precise'
      os_version = '12.04'
      os_kernel  = /3.\d+/
    elsif agent['platform'] =~ /ubuntu-14.04/
      os_name    = 'trusty'
      os_version = '14.04'
      os_kernel  = /3.\d+/
    elsif agent['platform'] =~ /ubuntu-14.10/
      os_name    = 'utopic'
      os_version = '14.10'
      os_kernel  = /3.\d+/
    elsif agent['platform'] =~ /ubuntu-15.04/
      os_name    = 'vivid'
      os_version = '15.04'
      os_kernel  = /3.\d+/
    elsif agent['platform'] =~ /ubuntu-15.10/
      os_name    = 'wily'
      os_version = '15.10'
      os_kernel  = /4.\d+/
    elsif agent['platform'] =~ /ubuntu-16.04/
      os_name    = 'xenial'
      os_version = '16.04'
      os_kernel  = /4.\d+/
    elsif agent['platform'] =~ /ubuntu-16.10/
      os_name    = 'yakkety'
      os_version = '16.10'
      os_kernel  = /4.\d+/
    else
      fail_test("Unknown Ubuntu platform: #{agent['platform']}")
    end

    if agent['platform'] =~ /x86_64|amd64/
      os_arch     = 'amd64'
      os_hardware = 'x86_64'
    elsif agent['platform'] =~ /ppc64el/
      os_arch     = 'ppc64le'
      os_hardware = 'ppc64le'
    else
      os_arch     = 'i386'
      os_hardware = 'i686'
    end

    step "Ensure the OS fact resolves as expected" do
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
    end

    step "Ensure the Processors fact resolves with reasonable values" do
      expected_processors = {
          'processors.count'         => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa'           => os_name == 'lucid' ? 'unknown' : os_hardware,
          'processors.models'        => os_arch == 'ppc64le' ? 'POWER8' : /"Intel\(R\).*"/
      }

      expected_processors.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end

    step "Ensure the identity fact resolves as expected" do
      expected_identity = {
          'identity.gid'        => '0',
          'identity.group'      => 'root',
          'identity.uid'        => '0',
          'identity.user'       => 'root',
          'identity.privileged' => 'true'
      }

      expected_identity.each do |fact, value|
        assert_equal(value, fact_on(agent, fact))
      end
    end

    step "Ensure the kernel fact resolves as expected" do
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
  end
end
