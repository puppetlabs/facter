# frozen_string_literal: true

module Facter
  module Util
    module Linux
      class Proc
        class << self
          def getenv_for_pid(pid, field)
            path = "/proc/#{pid}/environ"
            lines = Facter::Util::FileHelper.safe_readlines(path, [], "\0", chomp: true)
            lines.each do |line|
              key, value = line.split('=', 2)
              return value if key == field
            end
            nil
          end
        end
      end
    end
  end
end
