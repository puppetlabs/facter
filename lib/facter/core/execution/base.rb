class Facter::Core::Execution::Base

  def with_env(values)
    old = {}
    values.each do |var, value|
      # save the old value if it exists
      if old_val = ENV[var]
        old[var] = old_val
      end
      # set the new (temporary) value for the environment variable
      ENV[var] = value
    end
    # execute the caller's block, capture the return value
    rv = yield
  # use an ensure block to make absolutely sure we restore the variables
  ensure
    # restore the old values
    values.each do |var, value|
      if old.include?(var)
        ENV[var] = old[var]
      else
        # if there was no old value, delete the key from the current environment variables hash
        ENV.delete(var)
      end
    end
    # return the captured return value
    rv
  end

  def execute(command, options = {})

    on_fail = options.fetch(:on_fail, :raise)

    # Set LC_ALL and LANG to force i18n to C for the duration of this exec; this ensures that any code that parses the
    # output of the command can expect it to be in a consistent / predictable format / locale
    with_env 'LC_ALL' => 'C', 'LANG' => 'C' do

      expanded_command = expand_command(command)

      if expanded_command.nil?
        if on_fail == :raise
          raise Facter::Core::Execution::ExecutionFailure.new, "Could not execute '#{command}': command not found"
        else
          return on_fail
        end
      end

      out = ''

      begin
        wait_for_child = true
        out = %x{#{expanded_command}}.chomp
        wait_for_child = false
      rescue => detail
        if on_fail == :raise
          raise Facter::Core::Execution::ExecutionFailure.new, "Failed while executing '#{expanded_command}': #{detail.message}"
        else
          return on_fail
        end
      ensure
        if wait_for_child
          # We need to ensure that if this command exits early then any spawned
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

      out
    end
  end
end
