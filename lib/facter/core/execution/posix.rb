class Facter::Core::Execution::Posix < Facter::Core::Execution::Base

  DEFAULT_SEARCH_PATHS = ['/sbin', '/usr/sbin']

  def search_paths
    # Make sure facter is usable even for non-root users. Most commands
    # in /sbin (like ifconfig) can be run as non privileged users as
    # long as they do not modify anything - which we do not do with facter
    ENV['PATH'].split(File::PATH_SEPARATOR) + DEFAULT_SEARCH_PATHS
  end

  def which(bin)
    if absolute_path?(bin)
      return bin if File.executable?(bin) and File.file?(bin)
    else
      search_paths.each do |dir|
        dest = File.join(dir, bin)
        return dest if File.executable?(dest) and File.file?(dest)
      end
    end
    nil
  end

  ABSOLUTE_PATH_REGEX = %r{^/}

  def absolute_path?(path)
    !! (path =~ ABSOLUTE_PATH_REGEX)
  end

  DOUBLE_QUOTED_COMMAND = /^"(.+?)"(?:\s+(.*))?/
  SINGLE_QUOTED_COMMAND = /^'(.+?)'(?:\s+(.*))?/

  def expand_command(command)
    exe = nil
    args = nil

    if (match = (command.match(DOUBLE_QUOTED_COMMAND) || command.match(SINGLE_QUOTED_COMMAND)))
      exe, args = match.captures
    else
      exe, args = command.split(/ /,2)
    end

    if exe and (expanded = which(exe))
      expanded = "'#{expanded}'" if expanded.match(/\s/)
      expanded << " #{args}" if args

      return expanded
    end
  end
end
