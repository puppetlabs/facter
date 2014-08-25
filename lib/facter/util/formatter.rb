require 'yaml'

module Facter
  module Util
    module Formatter

      def self.format_json(hash)
        if Facter.json?
          JSON.pretty_generate(hash)
        else
          raise "Cannot format facts as JSON; 'json' library is not present"
        end
      end

      def self.format_yaml(hash)
        YAML.dump(hash)
      end

      def self.format_plaintext(hash)
        output = ''

        # Print the value of a single fact, otherwise print a list sorted by fact
        # name and separated by "=>"
        if hash.length == 1
          if !(value = hash.values.first).nil?
            output = value.is_a?(String) ? value : value.inspect
          end
        else
          hash.sort_by { |(name, value)| name }.each do |name,value|
            value = value.is_a?(String) ? value : value.inspect
            output << "#{name} => #{value}\n"
          end
        end

        output
      end
    end
  end
end
