require 'facter'
require 'facter/resolution'

class Facter::Fact
    attr_accessor :name, :searching, :ldapname

    # Create a new fact, with no resolution mechanisms.
    def initialize(name, options = {})
        @name = name.to_s.downcase.intern

        # LAK:NOTE: This is slow for many options, but generally we won't have any and at
        # worst we'll have one.  If we add more, this should be made more efficient.
        options.each do |name, value|
            case name
            when :ldapname: self.ldapname = value
            else
                raise ArgumentError, "Invalid fact option '%s'" % name
            end
        end

        @ldapname ||= @name.to_s

        @resolves = []
        @searching = false

        @value = nil
    end

    # Add a new resolution mechanism.  This requires a block, which will then
    # be evaluated in the context of the new mechanism.
    def add(&block)
        raise ArgumentError, "You must pass a block to Fact<instance>.add" unless block_given?

        resolve = Facter::Resolution.new(@name)

        resolve.instance_eval(&block)

        @resolves << resolve

        # Immediately sort the resolutions, so that we always have
        # a sorted list for looking up values.
        #  We always want to look them up in the order of number of
        # confines, so the most restricted resolution always wins.
        @resolves.sort! { |a, b| b.length <=> a.length }

        return resolve
    end

    # Flush any cached values.
    def flush
        @value = nil
        @suitable = nil
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

            if @resolves.length == 0
                Facter.debug "No resolves for %s" % @name
                return nil
            end

            @searching = true
            foundsuits = false
            @value = @resolves.inject(nil) { |result, resolve|
                next unless resolve.suitable?
                foundsuits = true

                tmp = resolve.value

                break tmp unless tmp.nil? or tmp == ""
            }
            @searching = false

            unless foundsuits
                Facter.debug "Found no suitable resolves of %s for %s" % [@resolves.length, @name]
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
end
