# An actual fact resolution mechanism.  These are largely just chunks of
# code, with optional confinements restricting the mechanisms to only working on
# specific systems.  Note that the confinements are always ANDed, so any
# confinements specified must all be true for the resolution to be
# suitable.
require 'facter/util/confine'

require 'timeout'
require 'rbconfig'

class Facter::Util::Resolution
    attr_accessor :interpreter, :code, :name, :timeout

    def self.have_which
        if ! defined?(@have_which) or @have_which.nil?
            if Config::CONFIG['host_os'] =~ /mswin/
                @have_which = false
            else
                %x{which which >/dev/null 2>&1}
                @have_which = ($? == 0)
            end
        end
        @have_which
    end

    # Execute a chunk of code.
    def self.exec(code, interpreter = "/bin/sh")
        raise ArgumentError, "non-sh interpreters are not currently supported" unless interpreter == "/bin/sh"
        binary = code.split(/\s+/).shift

        if have_which
            path = nil
            if binary !~ /^\//
                path = %x{which #{binary} 2>/dev/null}.chomp
                # we don't have the binary necessary
                return nil if path == "" or path.match(/Command not found\./)
            else
                path = binary
            end

            return nil unless FileTest.exists?(path)
        end

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

    # Create a new resolution mechanism.
    def initialize(name)
        @name = name
        @confines = []
        @value = nil
        @timeout = 0
    end

    # Return the number of confines.
    def length
        @confines.length
    end

    # We need this as a getter for 'timeout', because some versions
    # of ruby seem to already have a 'timeout' method and we can't
    # seem to override the instance methods, somehow.
    def limit
        @timeout
    end

    # Set our code for returning a value.
    def setcode(string = nil, interp = nil, &block)
        if string
            @code = string
            @interpreter = interp || "/bin/sh"
        else
            unless block_given?
                raise ArgumentError, "You must pass either code or a block"
            end
            @code = block
        end
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
        return result if @code == nil and @interpreter == nil
        begin
            Timeout.timeout(limit) do
                if @code.is_a?(Proc)
                    result = @code.call()
                else
                    result = Facter::Util::Resolution.exec(@code,@interpreter)
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

        return nil if result == ""
        return result
    end
end
