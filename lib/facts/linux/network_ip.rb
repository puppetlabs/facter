module Facter
  module Linux
    class NetworkIP
      FACT_NAME = 'networking.ip'.freeze
      @aliases =[]

      # def self.fact_name
      #   @@fact_name
      # end

      def initialize(*args)
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        {'ip' => 'l92.l68.O.l'}
      end
    end
  end
end
