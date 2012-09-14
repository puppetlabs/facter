# This provides an alias for RbConfig to Config for versions of Ruby older then
# version 1.8.5. This allows us to use RbConfig in place of the older Config in
# our code and still be compatible with at least Ruby 1.8.1.
require 'rbconfig'
require 'enumerator'

unless defined? ::RbConfig
  ::RbConfig = ::Config
end

module Facter
  module Util
    module MonkeyPatches
      module Lines
        def lines(separator = $/)
          if block_given?
            self.each_line(separator) {|line| yield line }
            return self
          else
            return enum_for(:each_line, separator)
          end
        end
      end
    end
  end
end

public
class String
  unless method_defined? :lines
    include Facter::Util::MonkeyPatches::Lines
  end
end

class IO
  unless method_defined? :lines
    include Facter::Util::MonkeyPatches::Lines
  end
end
