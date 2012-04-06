# An actual fact resolution mechanism.  These are largely just chunks of
# code, with optional confinements restricting the mechanisms to only working on
# specific systems.  Note that the confinements are always ANDed, so any
# confinements specified must all be true for the resolution to be
# suitable.
require 'facter/util/confine'
require 'facter/util/config'

require 'timeout'

class Facter::Util::Resolution
  attr_accessor :interpreter, :code, :name, :timeout

  INTERPRETER = Facter::Util::Config.is_windows? ? "cmd.exe" : "/bin/sh"

  def self.search_paths
    if Facter::Util::Config.is_windows?
      ENV['PATH'].split(File::PATH_SEPARATOR)
    else
      # Make sure facter is usable even for non-root users. Most commands
      # in /sbin (like ifconfig) can be run as non priviledged users as
      # long as they do not modify anything - which we do not do with facter
      ENV['PATH'].split(File::PATH_SEPARATOR) + [ '/sbin', '/usr/sbin' ]
    end
  end

  # taken from puppet: lib/puppet/util.rb
  def self.which(bin)
    if absolute_path?(bin)
      return bin if File.executable?(bin)
    else
      search_paths.each do |dir|
        dest = File.join(dir, bin)
        if Facter::Util::Config.is_windows? && File.extname(dest).empty?
          exts = ENV['PATHEXT']
          exts = exts ? exts.split(File::PATH_SEPARATOR) : %w[.COM .EXE .BAT .CMD]
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

  # taken from puppet: lib/puppet/util.rb
  def self.absolute_path?(path, platform=nil)
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

  def self.expand_command(command)
    if match = /^"([^"]+)"(?:\s+(.*))?/.match(command)
      exe, arguments = match.captures
      exe = which(exe) and [ "\"#{exe}\"", arguments ].compact.join(" ")
    else
      exe, arguments = command.split(/ /,2)
      exe = which(exe) and [ exe, arguments ].compact.join(" ")
    end
  end


  # Execute a program and return the output of that program.
  #
  # Returns nil if the program can't be found, or if there is a problem
  # executing the code.
  #
  def self.exec(code, interpreter = nil)
    Facter.warnonce "The interpreter parameter to 'exec' is deprecated and will be removed in a future version." if interpreter

    return nil unless code = expand_command(code)

    out = nil

    begin
      out = %x{#{code}}.chomp
    rescue => detail
      $stderr.puts detail
      return nil
    end

    if out == ""
      return nil
    else
      return out
    end
  end

  # Add a new confine to the resolution mechanism.
  def confine(confines)
    confines.each do |fact, values|
      @confines.push Facter::Util::Confine.new(fact, *values)
    end
  end

  def has_weight(weight)
    @weight = weight
  end

  # Create a new resolution mechanism.
  def initialize(name)
    @name = name
    @confines = []
    @value = nil
    @timeout = 0
    @weight = nil
  end

  # Return the importance of this resolution.
  def weight
    if @weight
      @weight
    else
      @confines.length
    end
  end

  # We need this as a getter for 'timeout', because some versions
  # of ruby seem to already have a 'timeout' method and we can't
  # seem to override the instance methods, somehow.
  def limit
    @timeout
  end

  # Set our code for returning a value.
  def setcode(string = nil, interp = nil, &block)
    Facter.warnonce "The interpreter parameter to 'setcode' is deprecated and will be removed in a future version." if interp
    if string
      @code = string
      @interpreter = interp || INTERPRETER
    else
      unless block_given?
        raise ArgumentError, "You must pass either code or a block"
      end
      @code = block
    end
  end

  def interpreter
    Facter.warnonce "The 'Facter::Util::Resolution.interpreter' method is deprecated and will be removed in a future version."
    @interpreter
  end

  def interpreter=(interp)
    Facter.warnonce "The 'Facter::Util::Resolution.interpreter=' method is deprecated and will be removed in a future version."
    @interpreter = interp
  end

  # Is this resolution mechanism suitable on the system in question?
  def suitable?
    unless defined? @suitable
      @suitable = ! @confines.detect { |confine| ! confine.true? }
    end

    return @suitable
  end

  def to_s
    return self.value()
  end

  # How we get a value for our resolution mechanism.
  def value
    result = nil
    return result if @code == nil

    starttime = Time.now.to_f

    begin
      Timeout.timeout(limit) do
        if @code.is_a?(Proc)
          result = @code.call()
        else
          result = Facter::Util::Resolution.exec(@code)
        end
      end
    rescue Timeout::Error => detail
      warn "Timed out seeking value for %s" % self.name

      # This call avoids zombies -- basically, create a thread that will
      # dezombify all of the child processes that we're ignoring because
      # of the timeout.
      Thread.new { Process.waitall }
      return nil
    rescue => details
      warn "Could not retrieve %s: %s" % [self.name, details]
      return nil
    end

    finishtime = Time.now.to_f
    ms = (finishtime - starttime) * 1000
    Facter.show_time "#{self.name}: #{"%.2f" % ms}ms"

    return nil if result == ""
    return result
  end
end
