# $Id$
#--
# Copyright 2004 Luke Kanies <luke@madstop.com>
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later), the Perl Artistic licence, or the
# Ruby licence.
# 
#--

#--------------------------------------------------------------------
class Facter
    include Comparable
    include Enumerable

FACTERVERSION = '1.0.1'
	# = Facter 1.0
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


    @@facts = {}
    GREEN = "[0;32m"
    RESET = "[0m"
    @@debug = 0
    @@os = nil
    @@osrel = nil

    attr_accessor :name, :os, :osrel, :hardware, :searching

	#----------------------------------------------------------------
	# module methods
	#----------------------------------------------------------------

    def Facter.version
        return FACTERVERSION
    end

    def Facter.debug(string)
        if string.nil?
            return
        end
        if @@debug != 0
            puts GREEN + string + RESET
        end
    end

	#----------------------------------------------------------------
	def Facter.[](name)
        if @@facts.include?(name.downcase)
            return @@facts[name.downcase]
        else
            return Facter.add(name)
        end
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def Facter.add(name)
        fact = nil
        dcname = name.downcase

        if @@facts.include?(dcname)
            fact = @@facts[dcname]
        else
            Facter.new(dcname)
            fact = @@facts[dcname]
        end

        if block_given?
            fact.add
        end

        return fact
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    class << self
        include Enumerable
        def each
            @@facts.each { |name,fact|
                if fact.suitable?
                    value = fact.value
                    unless value.nil?
                        yield name, fact.value
                    end
                end
            }
        end
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def Facter.reset
        @@facts.each { |name,fact|
            @@facts.delete(name)
        }
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
	# 
	def Facter.debugging(bit)
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
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    #def Facter.init
    #    @@os = @@facts["operatingsystem"].value
    #    @@release = @@facts["operatingsystemrelease"].value
    #end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def Facter.list
        return @@facts.keys
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def Facter.os
        return @@os
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def Facter.release
        return @@release
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def <=>(other)
        return self.value <=> other
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def initialize(name)
        @name = name.downcase
        if @@facts.include?(@name)
            raise "A fact named %s already exists" % name
        else
            @@facts[@name] = self
        end

        @resolves = []
        @searching = false
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    # as long as this doesn't work over the 'net, it should probably
    # be optimized to throw away any resolutions not valid for the machine
    # it's running on
    # but that's not currently done...
    def add
        resolve = Resolution.new(@name)
        yield(resolve)

        # skip resolves that will never be suitable for us
        return unless resolve.suitable?

        # insert resolves in order of number of tags
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
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    # iterate across all of the currently configured resolves
    # sort the resolves in order of most tags first, so we're getting
    # the most specific answers first, hopefully
    def each
#        @resolves.sort { |a,b|
#            puts "for tag %s, alength is %s and blength is %s" %
#                [@name, a.length, b.length]
#            b.length <=> a.length
#        }.each { |resolve|
#            yield resolve
#        }
        @resolves.each { |r| yield r }
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    # return a count of resolution mechanisms available
    def count
        return @resolves.length
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    # is this fact suitable for finding answers on this host?
    # again, this should really be optimizing by throwing away everything
    # not suitable, but...
    def suitable?
        return false if @resolves.length == 0

        unless defined? @suitable
            @suitable = false
            self.each { |resolve|
                if resolve.suitable?
                    @suitable = true
                    break
                end
            }
        end

        return @suitable
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    def value
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
            else
                Facter.debug "Unsuitable resolve %s for %s" % [resolve,@name]
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

        if @value.nil?
            # nothing
            Facter.debug("value for %s is still nil" % @name)
            return nil
        else
            return @value
        end
    end
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    class Resolution
        attr_accessor :interpreter, :code, :name

        def Resolution.exec(code, interpreter = "/bin/sh")
            if interpreter == "/bin/sh"
                binary = code.split(/\s+/).shift

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
                raise "non-sh interpreters are not currently supported"
            end
        end

        def initialize(name)
            @name = name
            @tags = []
        end

        def length
            @tags.length
        end

        def suitable?
            unless defined? @suitable
                @suitable = true
                if @tags.length == 0
                    #Facter.debug "'%s' has no tags" % @name
                    return true
                end
                @tags.each { |tag|
                    unless tag.true?
                        #Facter.debug "'%s' is false" % tag
                        @suitable = false
                    end
                }
            end

            return @suitable
        end

        def tag(fact,op,value)
            @tags.push Tag.new(fact,op,value)
        end

        def to_s
            return self.value()
        end

        # how we get a value for our resolution mechanism
        def value
            #puts "called %s value" % @name
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
	#----------------------------------------------------------------

	#----------------------------------------------------------------
    class Tag
        attr_accessor :fact, :op, :value

        def initialize(fact,op,value)
            @fact = fact
            if op == "="
                op = "=="
            end
            @op = op
            @value = value
        end

        def to_s
            return "'%s' %s '%s'" % [@fact,@op,@value]
        end

        def true?
            value = Facter[@fact].value

            if value.nil?
                return false
            end

            str = "'%s' %s '%s'" % [value,@op,@value]
            begin
                if eval(str)
                    return true
                else
                    return false
                end
            rescue => detail
                $stderr.puts "Failed to test '%s': %s" % [str,detail]
                return false
            end
        end
    end
	#----------------------------------------------------------------

    # Load all of the default facts
    def Facter.load
        Facter["OperatingSystem"].add { |obj|
            obj.code = 'uname -s'
        }

        Facter["OperatingSystemRelease"].add { |obj|
            obj.code = 'uname -r'
        }

        Facter["HardwareModel"].add { |obj|
            obj.code = 'uname -m'
            #obj.os = "SunOS"
            #obj.tag("operatingsystem","=","SunOS")
        }

        Facter["CfKey"].add { |obj|
            obj.code = proc {
                value = nil
                ["/usr/local/etc/cfkey.pub",
                    "/etc/cfkey.pub",
                    "/var/cfng/keys/localhost.pub",
                    "/var/cfengine/ppkeys/localhost.pub"
                ].each { |file|
                    if FileTest.file?(file)
                        File.open(file) { |openfile|
                            value = openfile.readlines.reject { |line|
                                line =~ /PUBLIC KEY/
                            }.collect { |line|
                                line.chomp
                            }.join("")
                        }
                    end
                    if value
                        break
                    end
                }

                value
            }
        }

        Facter["Domain"].add { |obj|
            obj.code = proc {
                if defined? $domain and ! $domain.nil?
                    $domain
                end
            }
        }
        Facter["Domain"].add { |obj|
            obj.code = proc {
                domain = Resolution.exec('domainname')
                return nil unless domain
                # make sure it's a real domain
                if domain =~ /.+\..+/
                    domain
                else
                    nil
                end
            }
        }
        Facter["Domain"].add { |obj|
            obj.code = proc {
                value = nil
                unless FileTest.exists?("/etc/resolv.conf")
                    return nil
                end
                File.open("/etc/resolv.conf") { |file|
                    # is the domain set?
                    file.each { |line|
                        if line =~ /domain\s+(\S+)/
                            value = $1
                            break
                        end
                    }
                }
                ! value and File.open("/etc/resolv.conf") { |file|
                    # is the search path set?
                    file.each { |line|
                        if line =~ /search\s+(\S+)/
                            value = $1
                            break
                        end
                    }
                }
                value
            }
        }
        Facter["Hostname"].add { |obj|
            obj.code = proc {
                hostname = nil
                name = Resolution.exec('hostname')
                if name =~ /^([\w-]+)\.(.+)$/
                    hostname = $1
                    # the Domain class uses this
                    $domain = $2
                else
                    hostname = name
                end
                hostname
            }
        }

        Facter["IPHostNumber"].add { |obj|
            obj.code = proc {
                require 'resolv'

                begin
                    hostname = Facter["hostname"].value
                    ip = Resolv.getaddress(hostname)
                    unless ip == "127.0.0.1"
                        ip
                    end
                rescue Resolv::ResolvError
                    nil
                rescue NoMethodError # i think this is a bug in resolv.rb?
                    nil
                end
            }
        }
        Facter["IPHostNumber"].add { |obj|
            obj.code = proc {
                hostname = Facter["hostname"].value
                # we need Hostname to exist for this to work
                list = Resolution.exec("host #{hostname}").chomp.split(/\s/)

                return nil unless list
                if defined? list[-1] and list[-1] =~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/
                    list[-1]
                end
            }
        }

        ["/etc/ssh","/usr/local/etc/ssh","/etc","/usr/local/etc"].each { |dir|
            {"SSHDSAKey" => "ssh_host_dsa_key.pub",
                    "SSHRSAKey" => "ssh_host_rsa_key.pub"}.each { |name,file|
                Facter[name].add { |obj|
                    obj.code = proc {
                        value = nil
                        filepath = File.join(dir,file)
                        if FileTest.file?(filepath)
                            begin
                                value = File.open(filepath).read.chomp
                            rescue
                                return nil
                            end
                        end
                        return value
                    } # end of proc
                } # end of add
            } # end of hash each
        } # end of dir each

        Facter["UniqueId"].add { |obj|
            obj.code = 'hostid'
            obj.interpreter = '/bin/sh'
            obj.tag("operatingsystem","=","SunOS")
            #obj.os = "SunOS"
        }
        Facter["HardwareISA"].add { |obj|
            obj.code = 'uname -p'
            obj.interpreter = '/bin/sh'
            #obj.os = "SunOS"
            obj.tag("operatingsystem","=","SunOS")
        }
        Facter["MacAddress"].add { |obj|
            #obj.os = "SunOS"
            obj.tag("operatingsystem","=","SunOS")
            obj.code = proc {
                ether = nil
                output = %x{/sbin/ifconfig -a}

                output =~ /ether (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
                ether = $1

                ether
            }
        }
        Facter["MacAddress"].add { |obj|
            #obj.os = "Darwin"
            obj.tag("operatingsystem","=","Darwin")
            obj.code = proc {
                ether = nil
                output = %x{/sbin/ifconfig}

                output.split(/^\S/).each { |str|
                    if str =~ /10baseT/ # we're wired
                        str =~ /ether (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                        ether = $1
                    end
                }

                ether
            }
        }
        Facter["IPHostnumber"].add { |obj|
            #obj.os = "Darwin"
            obj.tag("operatingsystem","=","Darwin")
            obj.code = proc {
                ip = nil
                output = %x{/sbin/ifconfig}

                output.split(/^\S/).each { |str|
                    if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                        tmp = $1
                        unless tmp =~ /127\./
                            ip = tmp
                            break
                        end
                    end
                }

                ip
            }
        }
        Facter["Hostname"].add { |obj|
            #obj.os = "Darwin"
            #obj.release = "R7"
            obj.tag("operatingsystem","=","Darwin")
            obj.tag("operatingsystemrelease","=","R7")
            obj.code = proc {
                hostname = nil
                File.open(
                    "/Library/Preferences/SystemConfiguration/preferences.plist"
                ) { |file|
                    found = 0
                    file.each { |line|
                        if line =~ /ComputerName/i
                            found = 1
                            next
                        end
                        if found == 1
                            if line =~ /<string>([\w|-]+)<\/string>/
                                hostname = $1
                                break
                            end
                        end
                    }
                }

                if hostname != nil
                    hostname
                end
            }
        }
        Facter["IPHostnumber"].add { |obj|
            #obj.os = "Darwin"
            #obj.release = "R6"
            obj.tag("operatingsystem","=","Darwin")
            obj.tag("operatingsystemrelease","=","R6")
            obj.code = proc {
                hostname = nil
                File.open(
                    "/var/db/SystemConfiguration/preferences.xml"
                ) { |file|
                    found = 0
                    file.each { |line|
                        if line =~ /ComputerName/i
                            found = 1
                            next
                        end
                        if found == 1
                            if line =~ /<string>([\w|-]+)<\/string>/
                                hostname = $1
                                break
                            end
                        end
                    }
                }

                if hostname != nil
                    hostname
                end
            }
        }
        Facter["IPHostnumber"].add { |obj|
            #obj.os = "Darwin"
            #obj.release = "R6"
            obj.tag("operatingsystem","=","Darwin")
            obj.tag("operatingsystemrelease","=","R6")
            obj.code = proc {
                ether = nil
                output = %x{/sbin/ifconfig}

                output =~ /HWaddr (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                ether = $1

                ether
            }
        }
        Facter["Distro"].add { |obj|
            #obj.os = "Linux"
            obj.tag("operatingsystem","=","Linux")
            obj.code = proc {
                if FileTest.exists?("/etc/debian_version")
                    return "Debian"
                elsif FileTest.exists?("/etc/gentoo-release")
                    return "Gentoo"
                elsif FileTest.exists?("/etc/fedora-release")
                    return "Fedora"
                elsif FileTest.exists?("/etc/redhat-release")
                    return "RedHat"
                elsif FileTest.exists?("/etc/SuSE-release")
                    return "SuSE"
                end
            }
        }
        Facter["ps"].add { |obj|
            obj.code = "echo 'ps -ef'"
        }
        Facter["ps"].add { |obj|
            obj.tag("operatingsystem","=","Darwin")
            obj.code = "echo 'ps -auxwww'"
        }

        Facter["id"].add { |obj|
            obj.tag("operatingsystem","=","Linux")
            obj.code = "whoami"
        }
    end

    Facter.load
end

# try to load a local fact library, if there happens to be one
begin
    require 'facter/local'
rescue LoadError
    # no worries
end
