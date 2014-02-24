class Facter::Core::Execution::Windows < Facter::Core::Execution::Base

  def search_paths
    ENV['PATH'].split(File::PATH_SEPARATOR)
  end

  DEFAULT_COMMAND_EXTENSIONS = %w[.COM .EXE .BAT .CMD]

  def which(bin)
    if absolute_path?(bin)
      return bin if File.executable?(bin)
    else
      search_paths.each do |dir|
        dest = File.join(dir, bin)
        dest.gsub!(File::SEPARATOR, File::ALT_SEPARATOR)
        if File.extname(dest).empty?
          exts = ENV['PATHEXT']
          exts = exts ? exts.split(File::PATH_SEPARATOR) : DEFAULT_COMMAND_EXTENSIONS
          exts.each do |ext|
            destext = dest + ext
            return destext if File.executable?(destext)
          end
        end
        return dest if File.executable?(dest)
      end
    end
    nil
  end

  slash = '[\\\\/]'
  name = '[^\\\\/]+'
  ABSOLUTE_PATH_REGEX = %r!^(([A-Z]:#{slash})|(#{slash}#{slash}#{name}#{slash}#{name})|(#{slash}#{slash}\?#{slash}#{name}))!i

  def absolute_path?(path)
    !! (path =~ ABSOLUTE_PATH_REGEX)
  end

  DOUBLE_QUOTED_COMMAND = /^"(.+?)"(?:\s+(.*))?/

  def expand_command(command)
    exe = nil
    args = nil

    if (match = command.match(DOUBLE_QUOTED_COMMAND))
      exe, args = match.captures
    else
      exe, args = command.split(/ /,2)
    end

    if exe and (expanded = which(exe))
      expanded = "\"#{expanded}\"" if expanded.match(/\s+/)
      expanded << " #{args}" if args

      return expanded
    end
  end
end
