module Facter
  module Acceptance
    module UserFactUtils

      # Determine paths for testing custom and external facts.
      # Paths vary by platform.

      # Retrieve the path of a non-standard directory for custom or external facts.
      #
      def get_user_fact_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            File.join('C:', 'Documents and Settings', 'All Users', 'Application Data', 'PuppetLabs', 'facter', 'custom')
          else
            File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'custom')
          end
        else
          File.join('/', 'opt', 'puppetlabs', 'facter', 'custom')
        end
      end

      # Retrieve the path of the standard facts.d directory.
      #
      def get_factsd_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            File.join('C:', 'Documents and Settings', 'All Users', 'Application Data', 'PuppetLabs', 'facter', 'facts.d')
          else
            File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'facts.d')
          end
        else
          File.join('/', 'opt', 'puppetlabs', 'facter', 'facts.d')
        end
      end

      # Retrieve the extension to use for an external fact script.
      # Windows uses '.bat' and everything else uses '.sh'
      def get_external_fact_script_extension(platform)
        if platform =~ /windows/
          '.bat'
        else
          '.sh'
        end
      end

      # Retrieve the path to default location of facter.conf file.
      #
      def get_default_fact_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            File.join('C:', 'Documents and Settings', 'All Users', 'Application Data', 'PuppetLabs', 'facter')
          else
            File.join('C:', 'ProgramData', 'PuppetLabs', 'facter')
          end
        else
          File.join('/', 'etc', 'puppetlabs', 'facter')
        end
      end
    end
  end
end
