module Puppet
  module Acceptance
    module CommandUtils
      def ruby_command(host)
        "env PATH=\"#{host['privatebindir']}:${PATH}\" ruby"
      end
      module_function :ruby_command

      def gem_command(host)
        if host['platform'] =~ /windows/
          "env PATH=\"#{host['privatebindir']}:${PATH}\" cmd /c gem"
        else
          "env PATH=\"#{host['privatebindir']}:${PATH}\" gem"
        end
      end
      module_function :gem_command
    end
  end
end
