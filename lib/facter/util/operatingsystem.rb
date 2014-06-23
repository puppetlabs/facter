module Facter
  module Util
    module Operatingsystem

      # @see http://www.freedesktop.org/software/systemd/man/os-release.html
      def self.os_release(file = '/etc/os-release')
        values = {}

        if File.readable?(file)
          File.readlines(file).each do |line|
            if (match = line.match(/^(\w+)=["']?(.+?)["']?$/))
              values[match[1]] = match[2]
            end
          end
        end

        values
      end
    end
  end
end
