module Puppet
  module Acceptance
    module CommandUtils
      def ruby_command(host)
        "env PATH=\"#{host['privatebindir']}:${PATH}\" ruby"
      end
      module_function :ruby_command
    end
  end
end
