module Facter
  module Linux
    class Os
      FACT_NAME = 'os'.freeze
      @aliases =[]

      def initialize(*args)
        @args = args
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        OsResolver.resolve(@args)
      end
    end
  end
end
