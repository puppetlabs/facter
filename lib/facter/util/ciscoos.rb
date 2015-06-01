module Facter
  module Util
    module CiscoOS 

      # @file follows the same format as os-release
      # @see http://www.freedesktop.org/software/systemd/man/os-release.html
      def self.cisco_release(file)
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
