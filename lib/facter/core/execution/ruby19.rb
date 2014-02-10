class Facter::Core::Execution::Ruby19 < Facter::Core::Execution::Base

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

      stdout_r, stdout_w = IO.pipe

      begin
        pid = Process.spawn(code, {:out => stdout_w.fileno, :err => :close})
        stdout_w.close

        Process.waitpid(pid)
        pid = nil
        out = stdout_r.read

        out.chomp!
      rescue => detail
        Facter.warn(detail.message)
        return nil
      ensure
        if pid
          Process.detach(pid)
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
