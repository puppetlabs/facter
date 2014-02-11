class Facter::Core::Execution::Base

  def search_paths
    if Facter::Util::Config.is_windows?
      ENV['PATH'].split(File::PATH_SEPARATOR)
    else
      # Make sure facter is usable even for non-root users. Most commands
      # in /sbin (like ifconfig) can be run as non priviledged users as
      # long as they do not modify anything - which we do not do with facter
      ENV['PATH'].split(File::PATH_SEPARATOR) + [ '/sbin', '/usr/sbin' ]
    end
  end

  def which(bin)
    if absolute_path?(bin)
      return bin if File.executable?(bin)
    else
      search_paths.each do |dir|
        dest = File.join(dir, bin)
        if Facter::Util::Config.is_windows?
          dest.gsub!(File::SEPARATOR, File::ALT_SEPARATOR)
          if File.extname(dest).empty?
            exts = ENV['PATHEXT']
            exts = exts ? exts.split(File::PATH_SEPARATOR) : %w[.COM .EXE .BAT .CMD]
            exts.each do |ext|
              destext = dest + ext
              return destext if File.executable?(destext)
            end
          end
        end
        return dest if File.executable?(dest)
      end
    end
    nil
  end

  def absolute_path?(path, platform=nil)
    # Escape once for the string literal, and once for the regex.
    slash = '[\\\\/]'
    name = '[^\\\\/]+'
    regexes = {
      :windows => %r!^(([A-Z]:#{slash})|(#{slash}#{slash}#{name}#{slash}#{name})|(#{slash}#{slash}\?#{slash}#{name}))!i,
      :posix   => %r!^/!,
    }
    platform ||= Facter::Util::Config.is_windows? ? :windows : :posix

    !! (path =~ regexes[platform])
  end

  def expand_command(command)
    if match = /^"(.+?)"(?:\s+(.*))?/.match(command)
      exe, arguments = match.captures
      exe = which(exe) and [ "\"#{exe}\"", arguments ].compact.join(" ")
    elsif match = /^'(.+?)'(?:\s+(.*))?/.match(command) and not Facter::Util::Config.is_windows?
      exe, arguments = match.captures
      exe = which(exe) and [ "'#{exe}'", arguments ].compact.join(" ")
    else
      exe, arguments = command.split(/ /,2)
      if exe = which(exe)
        # the binary was not quoted which means it contains no spaces. But the
        # full path to the binary may do so.
        exe = "\"#{exe}\"" if exe =~ /\s/ and Facter::Util::Config.is_windows?
        exe = "'#{exe}'" if exe =~ /\s/ and not Facter::Util::Config.is_windows?
        [ exe, arguments ].compact.join(" ")
      end
    end
  end

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

end
