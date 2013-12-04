require 'facter/util/confine'
require 'facter/util/config'

require 'timeout'

# This represents a fact resolution. A resolution is a concrete
# implementation of a fact. A single fact can have many resolutions and
# the correct resolution will be chosen at runtime. Each time
# {Facter.add} is called, a new resolution is created and added to the
# set of resolutions for the fact named in the call.  Each resolution
# has a {#has_weight weight}, which defines its priority over other
# resolutions, and a set of {#confine _confinements_}, which defines the
# conditions under which it will be chosen. All confinements must be
# satisfied for a fact to be considered _suitable_.
#
# @api public
class Facter::Util::Resolution
  # The timeout, in seconds, for evaluating this resolution. The default
  # is 0 which is equivalent to no timeout. This can be set using the
  # options hash argument to {Facter.add}.
  # @return [Integer]
  # @api public
  attr_accessor :timeout

  # @api private
  attr_accessor :code, :name
  attr_writer :value, :weight

  INTERPRETER = Facter::Util::Config.is_windows? ? "cmd.exe" : "/bin/sh"

  # Returns the locations to be searched when looking for a binary. This
  # is currently determined by the +PATH+ environment variable plus
  # `/sbin` and `/usr/sbin` when run on unix
  #
  # @return [Array<String>] the paths to be searched for binaries
  # @api private
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

  # Determines the full path to a binary. If the supplied filename does not
  # already describe an absolute path then different locations (determined
  # by {search_paths}) will be searched for a match.
  #
  # Returns nil if no matching executable can be found otherwise returns
  # the expanded pathname.
  #
  # @param bin [String] the executable to locate
  # @return [String,nil] the full path to the executable or nil if not
  #   found
  #
  # @api public
  def self.which(bin)
    if absolute_path?(bin)
      return bin if File.executable?(bin)
      if Facter::Util::Config.is_windows? and File.extname(bin).empty?
        exts = ENV['PATHEXT']
        exts = exts ? exts.split(File::PATH_SEPARATOR) : %w[.COM .EXE .BAT .CMD]
        exts.each do |ext|
          destext = bin + ext
          if File.executable?(destext)
            Facter.warnonce("Using Facter::Util::Resolution.which with an absolute path like #{bin} but no fileextension is deprecated. Please add the correct extension (#{ext})")
            return destext
          end
        end
      end
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

  # Determine in a platform-specific way whether a path is absolute. This
  # defaults to the local platform if none is specified.
  #
  # @param path [String] the path to check
  # @param platform [:posix,:windows,nil] the platform logic to use
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

  # Given a command line, this returns the command line with the
  # executable written as an absolute path. If the executable contains
  # spaces, it has be but in double quotes to be properly recognized.
  #
  # @param command [String] the command line
  #
  # @return [String, nil] the command line with the executable's path
  # expanded, or nil if the executable cannot be found.
  def self.expand_command(command)
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

  # Overrides environment variables within a block of code.  The
  # specified values will be set for the duration of the block, after
  # which the original values (if any) will be restored.
  #
  # @overload with_env(values, { || ... })
  #
  # @param values [Hash<String=>String>] A hash of the environment
  #   variables to override
  #
  # @return [void]
  #
  # @api public
  def self.with_env(values)
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

  # Executes a program and return the output of that program.
  #
  # Returns nil if the program can't be found, or if there is a problem
  # executing the code.
  #
  # @param code [String] the program to run
  # @return [String] the output of the program or an empty string
  #
  # @api public
  #
  # @note Since Facter 1.5.8 this strips trailing newlines from the
  #   returned value. If a fact will be used by versions of Facter older
  #   than 1.5.8 then you should call chomp the returned string.
  #
  # @overload exec(code)
  # @overload exec(code, interpreter = nil)
  #   @param [String] interpreter unused, only exists for backwards
  #     compatibility
  #   @deprecated
  def self.exec(code, interpreter = nil)
    Facter.warnonce "The interpreter parameter to 'exec' is deprecated and will be removed in a future version." if interpreter

    ## Set LC_ALL to force i18n to C for the duration of this exec; this ensures that any code that parses the
    ## output of the command can expect it to be in a consistent / predictable format / locale
    locale_vars = { "LC_ALL" => "C", "LANG" => "C" }
    with_env locale_vars  do

      if expanded_code = expand_command(code)
        # if we can find the binary, we'll run the command with the expanded path to the binary
        code = expanded_code
      else
        # if we cannot find the binary return '' on posix. On windows we'll still try to run the
        # command in case it is a shell-builtin. In case it is not, windows will raise Errno::ENOENT
        return '' unless Facter::Util::Config.is_windows?
        return '' if absolute_path?(code)
      end

      out = ''

      begin
        out = %x{#{code}}.chomp
        Facter.warnonce "Using Facter::Util::Resolution.exec with a shell built-in is deprecated. Most built-ins can be replaced with native ruby commands. If you really have to run a built-in, pass \"cmd /c your_builtin\" as a command (command responsible for this message was \"#{code}\")" unless expanded_code
      rescue Errno::ENOENT => detail
        # command not found on Windows
        return ''
      rescue => detail
        Facter.warn(detail)
        return ''
      end

      return out
    end
  end

  ##
  # Sets the conditions for this resolution to be used.  This method accepts
  # multiple forms of arguments to determine suitability.
  #
  # @return [void]
  #
  # @api public
  #
  # @overload confine(confines)
  #   Confine a fact to a specific fact value or values.  This form takes a
  #   hash of fact names and values. Every fact must match the values given for
  #   that fact, otherwise this resolution will not be considered suitable. The
  #   values given for a fact can be an array, in which case the value of the
  #   fact must be in the array for it to match.
  #   @param [Hash{String,Symbol=>String,Array<String>}] confines set of facts identified by the hash keys whose
  #     fact value must match the argument value.
  #   @example Confining to Linux
  #       Facter.add(:powerstates) do
  #         # This resolution only makes sense on linux systems
  #         confine :kernel => "Linux"
  #         setcode do
  #           File.read('/sys/power/states')
  #         end
  #       end
  #
  # @overload confine(confines, &block)
  #   Confine a fact to a block with the value of a specified fact yielded to
  #   the block.
  #   @param [String,Symbol] confines the fact name whose value should be
  #     yielded to the block
  #   @param [Proc] block determines the suitability of the fact.  If the block
  #     evaluates to `false` or `nil` then the confined fact will not be
  #     evaluated.
  #   @yield [value] the value of the fact identified by {confines}
  #   @example Confine the fact to a host with an ipaddress in a specific
  #     subnet
  #       confine :ipaddress do |addr|
  #         require 'ipaddr'
  #         IPAddr.new('192.168.0.0/16').include? addr
  #       end
  #
  # @overload confine(&block)
  #   Confine a fact to a block.  The fact will be evaluated only if the block
  #   evaluates to something other than `false` or `nil`.
  #   @param [Proc] block determines the suitability of the fact.  If the block
  #     evaluates to `false` or `nil` then the confined fact will not be
  #     evaluated.
  #   @example Confine the fact to systems with a specific file.
  #       confine { File.exist? '/bin/foo' }
  def confine(confines = nil, &block)
    case confines
    when Hash
      confines.each do |fact, values|
        @confines.push Facter::Util::Confine.new(fact, *values)
      end
    else
      if block
        if confines
          @confines.push Facter::Util::Confine.new(confines, &block)
        else
          @confines.push Facter::Util::Confine.new(&block)
        end
      else
      end
    end
  end

  # Sets the weight of this resolution. If multiple suitable resolutions
  # are found, the one with the highest weight will be used.  If weight
  # is not given, the number of confines set on a resolution will be
  # used as its weight (so that the most specific resolution is used).
  #
  # @param weight [Integer] the weight of this resolution
  #
  # @return [void]
  #
  # @api public
  def has_weight(weight)
    @weight = weight
  end

  # Create a new resolution mechanism.
  #
  # @param name [String] The name of the resolution. This is mostly
  #   unused and resolutions are treated as anonymous.
  # @return [void]
  #
  # @api private
  def initialize(name)
    @name = name
    @confines = []
    @value = nil
    @timeout = 0
    @weight = nil
  end

  # Returns the importance of this resolution. If the weight was not
  # given, the number of confines is used instead (so that a more
  # specific resolution wins over a less specific one).
  #
  # @return [Integer] the weight of this resolution
  #
  # @api private
  def weight
    if @weight
      @weight
    else
      @confines.length
    end
  end

  # (see #timeout)
  # This is another name for {#timeout}.
  # @comment We need this as a getter for 'timeout', because some versions
  #   of ruby seem to already have a 'timeout' method and we can't
  #   seem to override the instance methods, somehow.
  def limit
    @timeout
  end

  # Sets the code block or external program that will be evaluated to
  # get the value of the fact.
  #
  # @return [void]
  #
  # @overload setcode(string)
  #   Sets an external program to call to get the value of the resolution
  #   @param [String] string the external program to run to get the
  #     value
  #
  # @overload setcode(&block)
  #   Sets the resolution's value by evaluating a block at runtime
  #   @param [Proc] block The block to determine the resolution's value.
  #     This block is run when the fact is evaluated. Errors raised from
  #     inside the block are rescued and printed to stderr.
  #
  # @api public
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

  ##
  # on_flush accepts a block and executes the block when the resolution's value
  # is flushed.  This makes it possible to model a single, expensive system
  # call inside of a Ruby object and then define multiple dynamic facts which
  # resolve by sending messages to the model instance.  If one of the dynamic
  # facts is flushed then it can, in turn, flush the data stored in the model
  # instance to keep all of the dynamic facts in sync without making multiple,
  # expensive, system calls.
  #
  # Please see the Solaris zones fact for an example of how this feature may be
  # used.
  #
  # @see Facter::Util::Fact#flush
  # @see Facter::Util::Resolution#flush
  #
  # @api public
  def on_flush(&block)
    @on_flush_block = block
  end

  ##
  # flush executes the block, if any, stored by the {on_flush} method
  #
  # @see Facter::Util::Fact#flush
  # @see Facter::Util::Resolution#on_flush
  #
  # @api private
  def flush
    @on_flush_block.call if @on_flush_block
  end

  # @deprecated
  def interpreter
    Facter.warnonce "The 'Facter::Util::Resolution.interpreter' method is deprecated and will be removed in a future version."
    @interpreter
  end

  # @deprecated
  def interpreter=(interp)
    Facter.warnonce "The 'Facter::Util::Resolution.interpreter=' method is deprecated and will be removed in a future version."
    @interpreter = interp
  end

  # Is this resolution mechanism suitable on the system in question?
  #
  # @api private
  def suitable?
    unless defined? @suitable
      @suitable = ! @confines.detect { |confine| ! confine.true? }
    end

    return @suitable
  end

  # (see value)
  # @deprecated
  def to_s
    return self.value()
  end

  # Evaluates the code block or external program to get the value of the
  # fact.
  #
  # @api private
  def value
    return @value if @value
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
      Facter.warn "Timed out seeking value for %s" % self.name

      # This call avoids zombies -- basically, create a thread that will
      # dezombify all of the child processes that we're ignoring because
      # of the timeout.
      Thread.new { Process.waitall }
      return nil
    rescue => details
      Facter.warn "Could not retrieve %s: %s" % [self.name, details]
      return nil
    end

    finishtime = Time.now.to_f
    ms = (finishtime - starttime) * 1000
    Facter.show_time "#{self.name}: #{"%.2f" % ms}ms"

    return nil if result == ""
    return result
  end
end
