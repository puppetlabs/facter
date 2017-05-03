test_name "Facts should resolve as expected on Fedora" do
  tag 'risk:high'

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected on Fedora.
#
# Facts tested: os, processors, networking, identity, kernel
#

  confine :to, :platform => /fedora-2[0-2]/

  agents.each do |agent|
    /fedora-(?<os_version>\d\d)/ =~ agent['platform']

    if agent['platform'] =~ /x86_64/
      os_arch     = 'x86_64'
      os_hardware = 'x86_64'
    else
      os_arch     = 'i386'
      os_hardware = 'i686'
    end

    step "Ensure the OS fact resolves as expected" do
      expected_os = {
          'os.architecture'  => os_arch,
          'os.family'        => 'RedHat',
          'os.hardware'      => os_hardware,
          'os.name'          => /Fedora/,
          'os.release.full'  => os_version,
          'os.release.major' => os_version,
      }

      expected_os.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end

    step "Ensure the Processors fact resolves with reasonable values" do
      expected_processors = {
          'processors.count'         => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa'           => os_hardware,
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
      kernel_version = case os_version
                         when '20' then
                           '3.11'
                         when '21' then
                           '3.17'
                         when '22' then
                           '4.0'
                         else
                           'undefined'
                       end

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
  end
end
