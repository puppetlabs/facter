# This provides an alias for RbConfig to Config for versions of Ruby older then
# version 1.8.5. This allows us to use RbConfig in place of the older Config in
# our code and still be compatible with at least Ruby 1.8.1.
require 'rbconfig'
unless defined? ::RbConfig
  ::RbConfig = ::Config
end
