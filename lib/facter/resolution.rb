# An actual fact resolution mechanism.  These are largely just chunks of
# code, with optional confinements restricting the mechanisms to only working on
# specific systems.  Note that the confinements are always ANDed, so any
# confinements specified must all be true for the resolution to be
# suitable.
require 'facter/confine'

class Facter::Resolution
    attr_accessor :interpreter, :code, :name, :fact

    def self.have_which
        if @have_which.nil?
            %x{which which 2>/dev/null}
            @have_which = ($? == 0)
        end
        @have_which
    end

    # Execute a chunk of code.
    def self.exec(code, interpreter = "/bin/sh")
        if interpreter == "/bin/sh"
            binary = code.split(/\s+/).shift

            if have_which
                path = nil
                if binary !~ /^\//
                    path = %x{which #{binary} 2>/dev/null}.chomp
                    if path == ""
                        # we don't have the binary necessary
                        return nil
                    end
                else
                    path = binary
                end

                unless FileTest.exists?(path)
                    # our binary does not exist
                    return nil
                end
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
        else
            raise ArgumentError,
                "non-sh interpreters are not currently supported"
        end
    end

    # Add a new confine to the resolution mechanism.
    def confine(*args)
        if args[0].is_a? Hash
            args[0].each do |fact, values|
                @confines.push Facter::Confine.new(fact,*values)
            end
        else
            fact = args.shift
            @confines.push Facter::Confine.new(fact,*args)
        end
    end

    # Create a new resolution mechanism.
    def initialize(name)
        @name = name
        @confines = []
        @value = nil
    end

    # Return the number of confines.
    def length
        @confines.length
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

    # Set the name by which this parameter is known in LDAP.  The default
    # is just the fact name.
    def setldapname(name)
        @fact.ldapname = name.to_s
    end

    # Is this resolution mechanism suitable on the system in question?
    def suitable?
        unless defined? @suitable
            @suitable = true
            if @confines.length == 0
                return true
            end
            @confines.each { |confine|
                unless confine.true?
                    @suitable = false
                end
            }
        end

        return @suitable
    end

    # Set tags on our parent fact.
    def tag(*values)
        @fact.tag(*values)
    end

    def to_s
        return self.value()
    end

    # How we get a value for our resolution mechanism.
    def value
        value = nil

        if @code.is_a?(Proc)
            value = @code.call()
        else
            unless defined? @interpreter
                @interpreter = "/bin/sh"
            end
            if @code.nil?
                $stderr.puts "Code for %s is nil" % @name
            else
                value = Facter::Resolution.exec(@code,@interpreter)
            end
        end

        if value == ""
            value = nil
        end

        return value
    end
end
