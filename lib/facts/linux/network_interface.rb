module Facter
  module Linux
    class NetworkInterface
      def initialize(*args)
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        {'interface' => 'l0'}
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
