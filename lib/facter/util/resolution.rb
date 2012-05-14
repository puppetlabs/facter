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
  attr_writer :value, :weight

  INTERPRETER = Facter::Util::Config.is_windows? ? "cmd.exe" : "/bin/sh"

  def self.have_which
    if ! defined?(@have_which) or @have_which.nil?
      if Facter::Util::Config.is_windows?
        @have_which = false
      else
        %x{which which >/dev/null 2>&1}
        @have_which = $?.success?
      end
    end
    @have_which
  end

  #
  # Call this method with a block of code for which you would like to temporarily modify
  # one or more environment variables; the specified values will be set for the duration
  # of your block, after which the original values (if any) will be restored.
  #
  # [values] a Hash containing the key/value pairs of any environment variables that you
  # would like to temporarily override
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

  # Execute a program and return the output of that program.
  #
  # Returns nil if the program can't be found, or if there is a problem
  # executing the code.
  #
  def self.exec(code, interpreter = nil)
    Facter.warnonce "The interpreter parameter to 'exec' is deprecated and will be removed in a future version." if interpreter


    ## Set LANG to force i18n to C for the duration of this exec; this ensures that any code that parses the
    ## output of the command can expect it to be in a consistent / predictable format / locale
    with_env "LANG" => "C" do

      # Try to guess whether the specified code can be executed by looking at the
      # first word. If it cannot be found on the PATH defer on resolving the fact
      # by returning nil.
      # This only fails on shell built-ins, most of which are masked by stuff in
      # /bin or of dubious value anyways. In the worst case, "sh -c 'builtin'" can
      # be used to work around this limitation
      #
      # Windows' %x{} throws Errno::ENOENT when the command is not found, so we
      # can skip the check there. This is good, since builtins cannot be found
      # elsewhere.
      if have_which and !Facter::Util::Config.is_windows?
        path = nil
        binary = code.split.first
        if code =~ /^\//
          path = binary
        else
          path = %x{which #{binary} 2>/dev/null}.chomp
          # we don't have the binary necessary
          return if path == "" or path.match(/Command not found\./)
        end

        return unless FileTest.exists?(path)
      end

      out = nil

      begin
        out = %x{#{code}}.chomp
      rescue Errno::ENOENT => detail
        # command not found on Windows
        return
      rescue => detail
        $stderr.puts detail
        return
      end

      if out == ""
        return
      else
        return out
      end

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

  def preserve_whitespace
    @preserve_whitespace = true
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

    unless @preserve_whitespace
      result =  result.strip if result && result.respond_to?(:strip)
    end
    
    return nil if result == ""
    return result
  end
end
