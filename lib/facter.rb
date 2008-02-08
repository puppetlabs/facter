#--
# Copyright 2006 Luke Kanies <luke@madstop.com>
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
# 
#--

class Facter
    include Comparable
    include Enumerable

    FACTERVERSION = '1.3.8'
	# = Facter
    # Functions as a hash of 'facts' you might care about about your
    # system, such as mac address, IP address, Video card, etc.
    # returns them dynamically

	# == Synopsis
	#
    # Generally, treat <tt>Facter</tt> as a hash:
    # == Example
    # require 'facter'
    # puts Facter['operatingsystem']
    #


    @@facts = Hash.new { |hash, key|
        key = key.to_s.downcase.intern
        if hash.include?(key)
            hash[key]
        else
            nil
        end
    }
    GREEN = "[0;32m"
    RESET = "[0m"
    @@debug = 0

    attr_accessor :name, :searching, :ldapname

	# module methods

    # Return the version of the library.
    def self.version
        return FACTERVERSION
    end

    # Add some debugging
    def self.debug(string)
        if string.nil?
            return
        end
        if @@debug != 0
            puts GREEN + string + RESET
        end
    end

    # Return a fact object by name.  If you use this, you still have to call
    # 'value' on it to retrieve the actual value.
    def self.[](name)
        @@facts[name]
    end

    # Add a resolution mechanism for a named fact.  This does not distinguish
    # between adding a new fact and adding a new way to resolve a fact.
    def self.add(name, &block)
        fact = nil

        unless fact = @@facts[name]
            fact = Facter.new(name)
        end

        unless block
            return fact
        end

        fact.add(&block)

        return fact
    end

    class << self
        include Enumerable
        # Iterate across all of the facts.
        def each
            @@facts.each { |name,fact|
                if fact.suitable?
                    value = fact.value
                    unless value.nil?
                        yield name.to_s, fact.value
                    end
                end
            }
        end

        # Allow users to call fact names directly on the Facter class,
        # either retrieving the value or comparing it to an existing value.
        def method_missing(name, *args)
            question = false
            if name.to_s =~ /\?$/
                question = true
                name = name.to_s.sub(/\?$/,'')
            end

            if fact = @@facts[name]
                if question
                    value = fact.value.downcase
                    args.each do |arg|
                        if arg.to_s.downcase == value
                            return true
                        end
                    end

                    # If we got this far, there was no match.
                    return false
                else
                    return fact.value
                end
            else
                # Else, fail like a normal missing method.
                return super
            end
        end
    end

    # Clear all facts.  Mostly used for testing.
    def self.clear
        Facter.flush
        Facter.reset
    end

	# Set debugging on or off.
	def self.debugging(bit)
		if bit
            case bit
            when TrueClass: @@debug = 1
            when FalseClass: @@debug = 0
            when Fixnum: 
                if bit > 0
                    @@debug = 1
                else
                    @@debug = 0
                end
            when String:
                if bit.downcase == 'off'
                    @@debug = 0
                else
                    @@debug = 1
                end
            else
                @@debug = 0
            end
		else
			@@debug = 0
		end
	end

    # Flush all cached values.
    def self.flush
        @@facts.each { |name, fact| fact.flush }
    end

    # Return a list of all of the facts.
    def self.list
        return @@facts.keys
    end

    # Remove them all.
    def self.reset
        @@facts.clear
    end

    # Return a hash of all of our facts.
    def self.to_hash(*tags)
        @@facts.inject({}) do |h, ary|
            if ary[1].suitable? and (tags.empty? or ary[1].tagged?(*tags))
                value = ary[1].value
                if value
                    # For backwards compatibility, convert the fact name to a string.
                    h[ary[0].to_s] = value
                end
            end
            h
        end
    end

    def self.value(name)
        if fact = @@facts[name]
            fact.value
        else
            nil
        end
    end

    # Compare one value to another.
    def <=>(other)
        return self.value <=> other
    end

    # Are we the same?  Used for case statements.
    def ===(value)
        self.value == value
    end

    # Create a new fact, with no resolution mechanisms.
    def initialize(name)
        @name = name.to_s.downcase.intern
        if @@facts.include?(@name)
            raise ArgumentError, "A fact named %s already exists" % @name
        else
            @@facts[@name] = self
        end

        @resolves = []
        @tags = []
        @searching = false

        @value = nil

        @ldapname = name.to_s
    end

    # Add a new resolution mechanism.  This requires a block, which will then
    # be evaluated in the context of the new mechanism.
    def add(&block)
        unless block_given?
            raise ArgumentError, "You must pass a block to Fact<instance>.add"
        end

        resolve = Resolution.new(@name)

        resolve.fact = self

        resolve.instance_eval(&block)

        # skip resolves that will never be suitable for us
        unless resolve.suitable?
            return
        end

        # insert resolves in order of number of confinements
        inserted = false
        @resolves.each_with_index { |r,index|
            if resolve.length > r.length
                @resolves.insert(index,resolve)
                inserted = true
                break
            end
        }

        unless inserted
            @resolves.push resolve
        end
    end

    # Return a count of resolution mechanisms available.
    def count
        return @resolves.length
    end

    # Iterate across all of the fact resolution mechanisms and yield each in
    # turn.  These are inserted in order of most confinements.
    def each
        @resolves.each { |r| yield r }
    end

    # Flush any cached values.
    def flush
        @value = nil
        @suitable = nil
    end

    # Is this fact suitable for finding answers on this host?  This is used
    # to throw away any initially unsuitable mechanisms.
    def suitable?
        if @resolves.length == 0
            return false
        end

        unless defined? @suitable or (defined? @suitable and @suitable.nil?)
            @suitable = false
            @resolves.each { |resolve|
                if resolve.suitable?
                    @suitable = true
                    break
                end
            }
        end

        return @suitable
    end

    # Add one ore more tags
    def tag(*tags)
        tags.each do |t|
            t = t.to_s.downcase.intern
            @tags << t unless @tags.include?(t)
        end
    end

    # Is our fact tagged with all of the specified tags?
    def tagged?(*tags)
        tags.each do |t|
            unless @tags.include? t.to_s.downcase.intern
                return false
            end
        end

        return true
    end

    def tags
        @tags.dup
    end

    # Return the value for a given fact.  Searches through all of the mechanisms
    # and returns either the first value or nil.
    def value
        unless @value
            # make sure we don't get stuck in recursive dependency loops
            if @searching
                Facter.debug "Caught recursion on %s" % @name
                
                # return a cached value if we've got it
                if @value
                    return @value
                else
                    return nil
                end
            end
            @value = nil
            foundsuits = false

            if @resolves.length == 0
                Facter.debug "No resolves for %s" % @name
                return nil
            end

            @searching = true
            @resolves.each { |resolve|
                #Facter.debug "Searching resolves for %s" % @name
                if resolve.suitable?
                    @value = resolve.value
                    foundsuits = true
                end
                unless @value.nil? or @value == ""
                    break
                end
            }
            @searching = false

            unless foundsuits
                Facter.debug "Found no suitable resolves of %s for %s" %
                    [@resolves.length,@name]
            end
        end

        if @value.nil?
            # nothing
            Facter.debug("value for %s is still nil" % @name)
            return nil
        else
            return @value
        end
    end

    # An actual fact resolution mechanism.  These are largely just chunks of
    # code, with optional confinements restricting the mechanisms to only working on
    # specific systems.  Note that the confinements are always ANDed, so any
    # confinements specified must all be true for the resolution to be
    # suitable.
    class Resolution
        attr_accessor :interpreter, :code, :name, :fact

        def Resolution.have_which
            if @have_which.nil?
                %x{which which 2>/dev/null}
                @have_which = ($? == 0)
            end
            @have_which
        end

        # Execute a chunk of code.
        def Resolution.exec(code, interpreter = "/bin/sh")
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
                    @confines.push Confine.new(fact,*values)
                end
            else
                fact = args.shift
                @confines.push Confine.new(fact,*args)
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
                    value = Resolution.exec(@code,@interpreter)
                end
            end

            if value == ""
                value = nil
            end

            return value
        end

    end

    # A restricting tag for fact resolution mechanisms.  The tag must be true
    # for the resolution mechanism to be suitable.
    class Confine
        attr_accessor :fact, :op, :value

        # Add the tag.  Requires the fact name, an operator, and the value
        # we're comparing to.
        def initialize(fact, *values)
            fact = fact.to_s if fact.is_a? Symbol
            @fact = fact
            @values = values.collect do |value|
                if value.is_a? String
                    value
                else
                    value.to_s
                end
            end
        end

        def to_s
            return "'%s' '%s'" % [@fact, @values.join(",")]
        end

        # Evaluate the fact, returning true or false.
        def true?
            fact = nil
            unless fact = Facter[@fact]
                Facter.debug "No fact for %s" % @fact
                return false
            end
            value = fact.value

            if value.nil?
                return false
            end

            retval = @values.find { |v|
                if value.downcase == v.downcase
                    break true
                end
            }

            if retval
                retval = true
            else
                retval = false
            end

            return retval || false
        end
    end

    # Load all of the default facts
    def self.loadfacts
        Facter.add(:facterversion) do
            setcode { FACTERVERSION.to_s }
        end

        Facter.add(:rubyversion) do
            setcode { RUBY_VERSION.to_s }
        end

        Facter.add(:puppetversion) do
            setcode {
                begin
                    require 'puppet'
                    Puppet::PUPPETVERSION.to_s
                rescue LoadError
                    nil
                end
            }
        end

        Facter.add :rubysitedir do
            setcode do
                version = RUBY_VERSION.to_s.sub(/\.\d+$/, '')
                $:.find do |dir|
                    dir =~ /#{File.join("site_ruby", version)}$/
                end
            end
        end

        locals = []

        # Now find all our loadable facts
        factdirs = [] # All the places to check for facts
        
        # See if we can find any other facts in the regular Ruby lib
        # paths
        $:.each do |dir|
            fdir = File.join(dir, "facter")
            if FileTest.exists?(fdir) and FileTest.directory?(fdir)
                factdirs.push(fdir)
            end
        end
        # Also check anything in 'FACTERLIB'
        if ENV['FACTERLIB']
            ENV['FACTERLIB'].split(":").each do |fdir|
                factdirs.push(fdir)
            end
        end
        factdirs.each do |fdir|
            Dir.glob("#{fdir}/*.rb").each do |file|
                # Load here, rather than require, because otherwise
                # the facts won't get reloaded if someone calls
                # "loadfacts".  Really only important in testing, but,
                # well, it's important in testing.
                begin
                    load file
                rescue => detail
                    warn "Could not load %s: %s" %
                        [file, detail]
                end
            end
        end
        

        # Now try to get facts from the environment
        ENV.each do |name, value|
            if name =~ /^facter_?(\w+)$/i
                Facter.add($1) do
                    setcode { value }
                end
            end
        end
    end

    Facter.loadfacts
end

# $Id$
