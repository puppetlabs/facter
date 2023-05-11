# frozen_string_literal: true

module Facter
  module Util
    module Linux
      class Proc
        class << self
          def getenv_for_pid(pid, field)
            path = "/proc/#{pid}/environ"
            lines = Facter::Util::FileHelper.safe_readlines(path, nil, "\0", chomp: true)
            lines.each do |line|
              if line.slice(0, field.length) == field && line.slice(field.length) == '='
                return line.slice(field.length + 1, line.length - (field.length + 1))
              end
            end
            nil
          end
        end
      end
    end
  end
end
