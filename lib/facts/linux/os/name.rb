module Facter
  module Linux
    class OsName
      FACT_NAME = 'os.name'.freeze
      @aliases =[]

      def initialize(*args)
        @args = args
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact = OsResolver2.resolve(:name)
        return {FACT_NAME => fact}
      end
    end
  end
end
