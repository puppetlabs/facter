require 'facter/util/operatingsystem'

module Facter
  module Operatingsystem
    class Base
      def get_operatingsystem
        @operatingsystem ||= Facter.value(:kernel)
        @operatingsystem
      end

      def get_osfamily
        Facter.value(:kernel)
      end

      def get_operatingsystemrelease
        @operatingsystemrelease = Facter.value(:kernelrelease)
        @operatingsystemrelease
      end

      def get_operatingsystemmajorrelease
        if operatingsystemrelease = get_operatingsystemrelease
          if (releasemajor = operatingsystemrelease.split(".")[0])
            releasemajor
          end
        end
      end

      def get_operatingsystemminorrelease
        if operatingsystemrelease = get_operatingsystemrelease
          if (releaseminor = operatingsystemrelease.split(".")[1])
            if releaseminor.include? "-"
              releaseminor.split("-")[0]
            else
              releaseminor
            end
          end
        end
      end

      def get_operatingsystemrelease_hash
        release_hash = {}
        if releasemajor = get_operatingsystemmajorrelease
          release_hash["major"] = releasemajor
        end

        if releaseminor = get_operatingsystemminorrelease
          release_hash["minor"] = releaseminor
        end

        if release = get_operatingsystemrelease
          release_hash["full"] = release
        end
        release_hash
      end

      def has_lsb?
        false
      end
    end
  end
end
