class Facter::Core::Execution::Ruby18 < Facter::Core::Execution::Base

  def exec(code)

    ## Set LANG to force i18n to C for the duration of this exec; this ensures that any code that parses the
    ## output of the command can expect it to be in a consistent / predictable format / locale
    with_env "LANG" => "C" do

      if expanded_code = expand_command(code)
        # if we can find the binary, we'll run the command with the expanded path to the binary
        code = expanded_code
      else
        return nil
      end

      out = nil

      begin
        wait_for_child = true
        out = %x{#{code}}.chomp
        wait_for_child = false
      rescue => detail
        Facter.warn(detail.message)
        return nil
      ensure
        if wait_for_child
          # We need to ensure that if this code exits early then any spawned
          # children will be reaped. Process execution is frequently
          # terminated using Timeout.timeout but since the timeout isn't in
          # this scope we can't rescue the raised exception. The best that
          # we can do is determine if the child has exited, and if it hasn't
          # then we need to spawn a thread to wait for the child.
          #
          # Due to the limitations of Ruby 1.8 there aren't good ways to
          # asynchronously run a command and grab the PID of that command
          # using the standard library. The best we can do is blindly wait
          # on all processes and hope for the best. This issue is described
          # at https://tickets.puppetlabs.com/browse/FACT-150
          Thread.new { Process.waitall }
        end
      end

      if out == ""
        return nil
      else
        return out
      end
    end
  end
end
