# A util module for facter containing helper methods
module Facter
    module Util
        module Values
            module_function

            def convert(value)
                value = value.to_s if value.is_a?(Symbol)
                value = value.downcase if value.is_a?(String)
                value
            end    
        end
    end
end
