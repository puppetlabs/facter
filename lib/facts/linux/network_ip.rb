module Facter
  module Linux
    class NetworkIP
      def initialize(*args)
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        {'ip' => 'l92.l68.O.l'}
      end
    end
  end
end
