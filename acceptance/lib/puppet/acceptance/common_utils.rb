module Puppet
  module Acceptance
    module CommandUtils
      def ruby_command(host)
        if host['platform'] =~ /windows/ && !host.is_cygwin?
          "cmd /V /C \"set PATH=#{host['privatebindir']};!PATH! && ruby\""
        else
          "env PATH=\"#{host['privatebindir']}:${PATH}\" ruby"
        end
      end
      module_function :ruby_command
    end
  end
end
