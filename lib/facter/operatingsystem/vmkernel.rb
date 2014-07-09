require 'facter/operatingsystem/base'

module Facter
  module Operatingsystem
    class VMkernel < Base
      def get_operatingsystem
        "ESXi"
      end
    end
  end
end
