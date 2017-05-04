test_name "Facts should resolve as expected in Debian" do
  tag 'risk:high'

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in Debian.
#
# Facts tested: os, processors, networking, identity, kernel
#

  confine :to, :platform => /debian-6|debian-7|debian-8/

  agents.each do |agent|
    if agent['platform'] =~ /debian-6/
      codename   = 'squeeze'
      os_version = '6'
      os_kernel  = '2.6'
    elsif agent['platform'] =~ /debian-7/
      codename   = 'wheezy'
      os_version = '7'
      os_kernel  = '3.2'
    elsif agent['platform'] =~ /debian-8/
      codename   = 'jessie'
      os_version = '8'
      os_kernel  = '3.16'
    end

    if agent['platform'] =~ /amd64/
      os_arch     = 'amd64'
      os_hardware = 'x86_64'
    else
      os_arch     = 'i386'
      os_hardware = 'i686'
    end

    step "Ensure the OS fact resolves as expected" do
      expected_os = {
          'os.architecture'         => os_arch,
          'os.distro.codename'      => codename,
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
    end

    step "Ensure the Processors fact resolves with reasonable values" do
      expected_processors = {
          'processors.count'         => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa'           => /unknown|#{os_hardware}/,
          'processors.models'        => /"Intel\(R\).*"/
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
