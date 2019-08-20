# frozen_string_literal: true

module Facter
  module Macosx
    class NetworkInterface
      FACT_NAME = 'networking.interface'
      @aliases = []

      def initialize(*args)
        puts 'Dispatching to resolve: ' + args.inspect
        # constants = Linux.constants
        # puts constants
      end

      def call_the_resolver!
        Fact.new(FACT_NAME, 'l0')
      end
    end
  end
end

# fact_list = {
#   'networking' => 'Network',
#   'networking.interface' => 'NetworkInterface'
# }

# fact = 'networking.interface.i1.address'
# # networking.interface.i2.address

# tokens = fact.split('.')
# size = tokens.size-1

# size.times do |i|
#   elem = 0..size - i
#   if fact_list.has_key?(tokens[elem].join('.'))
#     found_fact = fact_list[tokens[elem].join('.')]
#     result = [found_fact, tokens - tokens[elem]]

#     puts result.inspect

#   end
# end
