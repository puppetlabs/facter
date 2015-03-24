module Facter
  module Acceptance
    module UserFactUtils

      # Determine paths for testing custom and external facts.
      # Paths vary by platform.

      # Retreive the path of a non-standard directory for custom or external facts.
      #
      def get_user_fact_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/custom'
          else
            'C:/ProgramData/PuppetLabs/facter/custom'
          end
        else
          '/opt/puppetlabs/facter/custom'
        end
      end

      # Retreive the path of the standard facts.d directory.
      #
      def get_factsd_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/facts.d'
          else
            'C:/ProgramData/PuppetLabs/facter/facts.d'
          end
        else
          '/opt/puppetlabs/facter/facts.d'
        end
      end

      # Retreive the extension to use for an external fact script.
      # Windows uses '.bat' and everything else uses '.sh'
      def get_external_fact_script_extension(platform)
        if platform =~ /windows/
          '.bat'
        else
          '.sh'
        end
      end
    end
  end
end
