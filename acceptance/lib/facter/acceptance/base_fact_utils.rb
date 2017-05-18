module Facter
  module Acceptance
    module BaseFactUtils

      # return a hash of expected facts for os, processors, and kernel facts
      #
      def os_processors_and_kernel_expected_facts(agent)
        if agent['platform'] =~ /aix-/
          aix_expected_facts(agent)
        elsif agent['platform'] =~ /cisco/
          cisco_expected_facts(agent)
        elsif agent['platform'] =~ /cumulus-/
          cumulus_expected_facts(agent)
        elsif agent['platform'] =~ /debian-/
          debian_expected_facts(agent)
        elsif agent['platform'] =~ /el-|centos-/
          el_expected_facts(agent)
        elsif agent['platform'] =~ /eos-/ # arista
          eos_expected_facts(agent)
        elsif agent['platform'] =~ /fedora-/
          fedora_expected_facts(agent)
        elsif agent['platform'] =~ /huaweios-/
          huawei_expected_facts(agent)
        elsif agent['platform'] =~ /osx-/
          osx_expected_facts(agent)
        elsif agent['platform'] =~ /sles-/
          sles_expected_facts(agent)
        elsif agent['platform'] =~ /solaris-/
          solaris_expected_facts(agent)
        elsif agent['platform'] =~ /ubuntu-/
          ubuntu_expected_facts(agent)
        elsif agent['platform'] =~ /windows-/
          windows_expected_facts(agent)
        else
          raise "unknown agent type being tested #{agent['platform']}"
        end
      end

      # return the value from the facter json parsed set of results using the fact path separated using '.'s
      #
      def json_result_fact_by_key_path(results, fact)
        fact.split('.').each do |key|
          results = results[key]
        end
        results
      end

      # return a hash of expected os.distro facts if lsb_release is installed on the agent host
      # otherwise return an empty hash
      #
      def linux_expected_os_distro_facts(agent)
        expected_os_distro_specification = {}
        lsb_release_output               = on(agent, 'lsb_release -a', :accept_all_exit_codes => true).stdout.chomp
        if lsb_release_output.empty?
          expected_os_distro_facts = {}
        else
          os_distro_id            = lsb_release_output.match(/Distributor ID:\s+(.*)/)[1]
          os_distro_description   = lsb_release_output.match(/Description:\s+(.*)/)[1]
          os_distro_codename      = lsb_release_output.match(/Codename:\s+(.*)/)[1]
          os_distro_release_full  = lsb_release_output.match(/Release:\s+(\d+.\d+)/)[1]
          os_distro_release_major = lsb_release_output.match(/Release:\s+(\d+).\d+/)[1]
          os_distro_release_minor = lsb_release_output.match(/Release:\s+\d+.(\d+)/)[1]
          if lsb_release_output.match(/LSB Version:\s+(.*)/)
            os_distro_specification          = lsb_release_output.match(/LSB Version:\s+(.*)/)[1]
            expected_os_distro_specification = {
                'os.distro.specification' => os_distro_specification
            }
          end

          expected_os_distro_facts = {
              'os.distro.codename'      => os_distro_codename,
              'os.distro.description'   => os_distro_description,
              'os.distro.id'            => os_distro_id,
              'os.distro.release.full'  => os_distro_release_full,
              'os.distro.release.major' => os_distro_release_major,
              'os.distro.release.minor' => os_distro_release_minor,
          }
        end
        expected_os_distro_facts.merge(expected_os_distro_specification)
      end

      # Return a hash of kernel facts for the common Linux styles
      #
      def expected_linux_kernel_facts(agent)
        kernel             = on(agent, 'uname -s').stdout.chomp
        kernel_release     = on(agent, 'uname -r').stdout.chomp
        kernel_version     = kernel_release.match(/(\d+\.\d+.\d+)/)[1]
        kernel_maj_version = kernel_release.match(/(\d+\.\d+)\.\d+/)[1]

        expected_kernel_facts = {
            'kernel'           => kernel,
            'kernelrelease'    => kernel_release,
            'kernelversion'    => kernel_version,
            'kernelmajversion' => kernel_maj_version,
        }
        expected_kernel_facts
      end

      # AIX
      def aix_expected_facts(agent)
        arch_result        = on(agent, '/usr/sbin/lsattr -El proc0 -a type').stdout.chomp
        os_arch            = arch_result.match(/[^ ]+ ([^ ]+) /)[1]
        hardware_result    = on(agent, '/usr/sbin/lsattr -El sys0 -a modelname').stdout.chomp
        os_hardware        = hardware_result.match(/[^ ]+ ([^ ]+) /)[1]
        kernel             = on(agent, 'uname -s').stdout.chomp
        kernel_release     = on(agent, '/usr/bin/oslevel -s').stdout.chomp
        kernel_version     = kernel_release.match(/^(....)/)[1]
        kernel_maj_version = kernel_release.match(/^(....)/)[1]
        os_release_full    = kernel_release
        os_release_major   = kernel_maj_version

        expected_facts = {
            'os.architecture'   => os_arch,
            'os.family'         => 'AIX',
            'os.hardware'       => os_hardware,
            'os.name'           => 'AIX',
            'os.release.full'   => os_release_full,
            'os.release.major'  => os_release_major,
            'processors.count'  => /[1-9]+/,
            'processors.isa'    => /[Pp]ower[Pp][Cc]/,
            'processors.models' => /[Pp]ower[Pp][Cc]/,
            'kernel'            => kernel,
            'kernelrelease'     => kernel_release,
            'kernelversion'     => kernel_version,
            'kernelmajversion'  => kernel_maj_version,
        }
        expected_facts
      end

      # Cisco
      def cisco_expected_facts(agent)
        os_arch      = 'x86_64'
        os_hardware  = on(agent, 'uname -m').stdout.chomp
        release_file = on(agent, 'cat /etc/cisco-release', :acceptable_exit_codes => [0, 1]).stdout
        if release_file.empty?
          release_file = on(agent, 'cat /etc/os-release').stdout
        end
        os_name          = release_file.match(/ID=(.*)/)[1]
        os_family        = release_file.match(/ID_LIKE=\"?([^ \n]+)\s*.*/)[1]
        os_release_full  = release_file.match(/VERSION="([^"]+)"/)[1]
        os_release_major = os_release_full.match(/(\d+)\.\d+/)[1]
        os_release_minor = os_release_full.match(/\d+\.(\d+)/)[1]

        expected_kernel_facts = expected_linux_kernel_facts(agent)
        expected_facts        = {
            'os.architecture'          => os_arch,
            'os.family'                => os_family,
            'os.hardware'              => os_hardware,
            'os.name'                  => os_name,
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /#{os_hardware}|unknown/,
            'processors.models'        => /Westmere/,
        }
        expected_facts.merge(expected_kernel_facts)
      end

      # Cumulus
      def cumulus_expected_facts(agent)
        os_version_file  = on(agent, 'cat /etc/lsb-release').stdout.chomp
        os_release_full  = os_version_file.match(/DISTRIB_RELEASE=(\d+\.\d+\.\d+)/)[1]
        os_release_major = os_version_file.match(/DISTRIB_RELEASE=(\d+)\.\d+\.\d+/)[1]
        os_release_minor = os_version_file.match(/DISTRIB_RELEASE=\d+\.(\d+)\.\d+/)[1]
        os_arch          = on(agent, 'uname -m').stdout.chomp
        os_hardware      = os_arch

        expected_kernel_facts    = expected_linux_kernel_facts(agent)
        expected_os_distro_facts = linux_expected_os_distro_facts(agent)
        expected_facts           = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'CumulusLinux',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /unknown|#{os_hardware}/,
            'processors.models'        => /"Intel\(R\).*"/,
        }
        expected_facts.merge(expected_os_distro_facts).merge(expected_kernel_facts)
      end

      # Debian
      def debian_expected_facts(agent)
        os_version_file  = on(agent, 'cat /etc/debian_version').stdout.chomp
        os_release_full  = os_version_file.match(/(\d+\.?\d+)?/)[1]
        os_release_major = os_version_file.match(/(\d+)\.?\d+?/)[1]
        os_release_minor = os_version_file.match(/\d+\.?(\d+)?/)[1]
        os_release_minor = '0' if os_release_minor.nil?
        os_hardware      = on(agent, 'uname -m').stdout.chomp
        os_arch          = os_hardware =~ /x86_64/ ? 'amd64' : 'i386'

        expected_kernel_facts    = expected_linux_kernel_facts(agent)
        expected_os_distro_facts = linux_expected_os_distro_facts(agent)
        expected_facts           = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Debian',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /unknown|#{os_hardware}/,
            'processors.models'        => /"Intel\(R\).*"/,
        }
        expected_facts.merge(expected_os_distro_facts).merge(expected_kernel_facts)
      end

      # el (RedHat, Centos)
      def el_expected_facts(agent)
        release_file_results = ''
        %w[ /etc/oracle-release /etc/enterprise-release /etc/redhat-release ].each do |release_path|
          release_file_results = on(agent, "cat #{release_path}", :acceptable_exit_codes => [0, 1]).stdout
          break unless release_file_results.empty?
        end
        os_release_full  = release_file_results.match(/.*release (\d+.\d+)/)[1]
        os_release_major = release_file_results.match(/.*release (\d+).\d+/)[1]
        os_release_minor = release_file_results.match(/.*release \d+.(\d+)/)[1]
        case release_file_results.downcase
          when /centos/
            os_name = 'CentOS'
          when /oracle/
            os_name = 'OracleLinux'
          when /scientific/
            os_name = 'Scientific'
          else
            os_name = 'RedHat'
        end
        os_hardware = on(agent, 'uname -m').stdout.chomp
        os_arch     = on(agent, 'uname -i').stdout.chomp
        if os_arch =~ /86/
          processor_model_pattern = 'Intel\(R\)'
        else
          processor_model_pattern = '' # s390x does not populate a model value in /proc/cpuinfo
        end

        expected_kernel_facts    = expected_linux_kernel_facts(agent)
        expected_os_distro_facts = linux_expected_os_distro_facts(agent)
        expected_facts           = {
            'os.architecture'          => os_arch,
            'os.family'                => 'RedHat',
            'os.hardware'              => os_hardware,
            'os.name'                  => os_name,
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /#{processor_model_pattern}/,
        }
        expected_facts.merge(expected_os_distro_facts).merge(expected_kernel_facts)
      end

      # eos Arista
      def eos_expected_facts(agent)
        os_arch            = on(agent, 'uname -i').stdout.chomp
        os_hardware        = on(agent, 'uname -m').stdout.chomp
        eos_release_file   = on(agent, 'cat /etc/Eos-release').stdout.chomp
        os_release_full    = eos_release_file.match(/Arista Networks EOS (\d+\.\d+\.\d+[A-M]?)/)[1]
        os_release_major   = eos_release_file.match(/Arista Networks EOS (\d+)\.\d+\.\d+[A-M]?/)[1]
        os_release_minor   = eos_release_file.match(/Arista Networks EOS \d+\.(\d+)\.\d+[A-M]?/)[1]
        kernel             = on(agent, 'uname -s').stdout.chomp
        kernel_release     = on(agent, 'uname -r').stdout.chomp
        kernel_version     = kernel_release.match(/(\d+\.\d+.\d+\.[^-]*)-/)[1]
        kernel_maj_version = kernel_release.match(/(\d+\.\d+)\.\d+/)[1]

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Linux',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'AristaEOS',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /Intel\(R\)/,
            'kernel'                   => kernel,
            'kernelrelease'            => kernel_release,
            'kernelversion'            => kernel_version,
            'kernelmajversion'         => kernel_maj_version,
        }
        expected_facts
      end

      # fedora
      def fedora_expected_facts(agent)
        os_arch             = on(agent, 'uname -i').stdout.chomp
        os_hardware         = on(agent, 'uname -m').stdout.chomp
        fedora_release_file = on(agent, 'cat /etc/fedora-release').stdout.chomp
        os_release_full     = fedora_release_file.match(/release (\d+) /)[1]
        os_release_major    = fedora_release_file.match(/release (\d+) /)[1]

        expected_kernel_facts = expected_linux_kernel_facts(agent)
        expected_facts        = {
            'os.architecture'          => os_arch,
            'os.family'                => 'RedHat',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Fedora',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /"Intel\(R\).*"/,
        }
        expected_facts.merge(expected_kernel_facts)
      end

      # huawei
      def huawei_expected_facts(agent)
        os_version_file  = on(agent, 'cat /etc/debian_version').stdout.chomp
        os_release_full  = os_version_file.match(/(\d+\.?\d+)?/)[1]
        os_release_major = os_version_file.match(/(\d+)\.?\d+?/)[1]
        os_release_minor = os_version_file.match(/\d+\.?(\d+)?/)[1]
        os_release_minor = '0' if os_release_minor.nil?
        os_hardware      = on(agent, 'uname -m').stdout.chomp
        os_arch          = os_hardware

        expected_kernel_facts = expected_linux_kernel_facts(agent)
        expected_facts        = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Debian',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => 'unknown',
        }
        expected_facts.merge(expected_kernel_facts)
      end

      # osx
      def osx_expected_facts(agent)
        os_arch              = on(agent, 'uname -m').stdout.chomp
        os_hardware          = os_arch
        os_family            = on(agent, 'uname -s').stdout.chomp
        sw_vers              = on(agent, '/usr/bin/sw_vers').stdout
        macosx_build         = sw_vers.match(/BuildVersion:\s+(.*)/)[1]
        macosx_product       = sw_vers.match(/ProductName:\s+(.*)/)[1]
        macosx_version_full  = sw_vers.match(/ProductVersion:\s+(.*)/)[1]
        macosx_version_major = macosx_version_full.match(/(\d+\.\d+)(\.\d+)?/)[1]
        minor_match          = macosx_version_full.match(/\d+\.\d+\.(\d+)?/)
        if minor_match.nil?
          macosx_version_minor = '0'
        else
          macosx_version_minor = minor_match[1]
        end
        os_release_full    = on(agent, 'uname -r').stdout.chomp
        os_release_major   = os_release_full.match(/(\d+)\.\d+\.\d+/)[1]
        os_release_minor   = os_release_full.match(/\d+\.(\d+)\.\d+/)[1]
        kernel             = on(agent, 'uname -s').stdout.chomp
        kernel_release     = on(agent, 'uname -r').stdout.chomp
        kernel_version     = kernel_release
        kernel_maj_version = kernel_version.match(/(\d+\.\d+)\.\d+/)[1]

        expected_facts = {
            'os.architecture'          => os_hardware,
            'os.family'                => os_family,
            'os.hardware'              => os_hardware,
            'os.name'                  => os_family,
            'os.macosx.build'          => macosx_build,
            'os.macosx.product'        => macosx_product,
            'os.macosx.version.full'   => macosx_version_full,
            'os.macosx.version.major'  => macosx_version_major,
            'os.macosx.version.minor'  => macosx_version_minor,
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => 'i386',
            'processors.models'        => /"Intel\(R\).*"/,
            'kernel'                   => kernel,
            'kernelrelease'            => kernel_release,
            'kernelversion'            => kernel_version,
            'kernelmajversion'         => kernel_maj_version,
        }
        expected_facts
      end

      # SLES
      def sles_expected_facts(agent)
        suse_release_file = on(agent, 'cat /etc/SuSE-release').stdout
        os_release_major  = suse_release_file.match(/VERSION\s+=\s+(\d+)/)[1]
        os_release_minor  = suse_release_file.match(/PATCHLEVEL\s+=\s+(\d+)/)[1]
        os_hardware       = on(agent, 'uname -m').stdout.chomp
        os_arch           = on(agent, 'uname -i').stdout.chomp
        if os_arch =~ /86/
          processor_model_pattern = 'Intel\(R\)'
        else
          processor_model_pattern = '' # s390x does not populate a model value in /proc/cpuinfo
        end

        expected_kernel_facts = expected_linux_kernel_facts(agent)
        expected_facts        = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Suse',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'SLES',
            'os.release.full'          => "#{os_release_major}.#{os_release_minor}",
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /#{processor_model_pattern}/,
        }
        expected_facts.merge(expected_kernel_facts)
      end

      # Solaris
      def solaris_expected_facts(agent)
        release_file           = on(agent, 'cat /etc/release').stdout
        # Oracle Solaris 10 1/13 s10x_u11wos_24a X86
        # Oracle Solaris 10 9/10 s10s_u9wos_14a SPARC
        solaris_10_regex       = /Solaris \d+ \d+\/\d+ s(\d+)[sx]?_u(\d+)wos_/
        # Oracle Solaris 11 11/11 X86
        solaris_11_regex       = /Solaris (\d+) /
        # Oracle Solaris 11.2 X86
        solaris_11_minor_regex = /Solaris (\d+)(\.\d+) /
        if release_file =~ solaris_10_regex
          solaris         = release_file.match(solaris_10_regex)
          os_release_full = "#{solaris[1]}_u#{solaris[2]}"
          os_version      = "#{solaris[1]}"
        elsif release_file =~ solaris_11_minor_regex
          solaris         = release_file.match(solaris_11_minor_regex)
          os_release_full = "#{solaris[1]}#{solaris[2]}"
          os_version      = "#{solaris[1]}"
        elsif release_file =~ solaris_11_regex
          solaris         = release_file.match(solaris_11_regex)
          os_release_full = "#{solaris[1]}.0"
          os_version      = "#{solaris[1]}"
        else
          raise "Unknown Solaris version #{agent['platform']} #{release_file}"
        end
        os_arch  = on(agent, 'uname -m').stdout.chomp
        proc_isa = on(agent, 'uname -p').stdout.chomp
        if proc_isa =~ /sparc/
          proc_models = /.*SPARC.*/
        else
          proc_models = /Intel\(r\).*/
        end
        kernel         = on(agent, 'uname -s').stdout.chomp
        kernel_release = on(agent, 'uname -r').stdout.chomp
        kernel_version = on(agent, 'uname -v').stdout.chomp
        if kernel_version =~ /Generic/
          kernel_maj_version = kernel_version
        else
          kernel_maj_version = kernel_release.match(/\d+\.(\d+)/)[1]
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Solaris',
            'os.hardware'              => os_arch,
            'os.name'                  => 'Solaris',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_version,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => proc_isa,
            'processors.models'        => proc_models,
            'kernel'                   => kernel,
            'kernelrelease'            => kernel_release,
            'kernelversion'            => kernel_version,
            'kernelmajversion'         => kernel_maj_version,
        }
        expected_facts
      end

      # Ubuntu
      def ubuntu_expected_facts(agent)
        lsb_release_file = on(agent, 'cat /etc/lsb-release').stdout.chomp
        os_version       = lsb_release_file.match(/DISTRIB_RELEASE=(\d+\.\d+)?(:\\.\\d+)*/)[1]
        codename         = lsb_release_file.match(/DISTRIB_CODENAME=(.*)/)[1]
        os_hardware      = on(agent, 'uname -m').stdout.chomp
        os_arch          = os_hardware =~ /x86_64/ ? 'amd64' : 'i386'

        expected_kernel_facts = expected_linux_kernel_facts(agent)
        expected_facts        = {
            'os.architecture'          => os_arch,
            'os.distro.codename'       => codename,
            'os.distro.description'    => /Ubuntu #{os_version}/,
            'os.distro.id'             => 'Ubuntu',
            'os.distro.release.full'   => os_version,
            'os.distro.release.major'  => os_version,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Ubuntu',
            'os.release.full'          => os_version,
            'os.release.major'         => os_version,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /"Intel\(R\).*"/,
        }
        expected_facts.merge(expected_kernel_facts)
      end

      # Windows
      def windows_expected_facts(agent)
        system_info = on(agent, 'systeminfo').stdout
        os_name_string = system_info.match(/OS Name:\s+(.*)/)[1]
        os_release_full = os_name_string.gsub(/Microsoft Windows\s*(Server\s*)?/, '').gsub(/Standard|Enterprise/, '').strip
        kernel_release = system_info.match(/OS Version:\s+(\d+\.\d+\.\d+) /)[1]
        kernel_version = kernel_release
        kernel_maj_version = kernel_release.match(/(\d+\.\d+)\.\d+/)[1]
        os_architecture_string = on(agent, 'echo "" | wmic os get osarchitecture').stdout
        if os_architecture_string =~ /64/
          os_arch     = 'x64'
          os_hardware = 'x86_64'
        else
          os_arch     = 'x86'
          os_hardware = 'i686'
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'windows',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'windows',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_release_full,
            'os.windows.system32'      => /C:\\(WINDOWS|Windows)\\(system32|sysnative)/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /x86|x64/,
            'processors.models'        => /"Intel\(R\).*"/,
            'kernel'                   => 'windows',
            'kernelrelease'            => kernel_release,
            'kernelversion'            => kernel_version,
            'kernelmajversion'         => kernel_maj_version,
        }
        expected_facts
      end
    end
  end
end
