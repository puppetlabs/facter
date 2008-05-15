require 'facter'

# Load facts on demand.
class Facter::Util::Loader
    # Load all resolutions for a single fact.
    def load(fact)
        # Now load from the search path
        shortname = fact.to_s.downcase
        load_env(shortname)

        filename = shortname + ".rb"
        search_path.each do |dir|
            # Load individual files
            file = File.join(dir, filename)

            # We have to specify Kernel.load, because we have a load method.
            Kernel.load(file) if FileTest.exist?(file)

            # And load any directories matching the name
            factdir = File.join(dir, shortname)
            load_dir(factdir) if FileTest.directory?(factdir)
        end
    end

    # Load all facts from all directories.
    def load_all
        load_env

        search_path.each do |dir|
            Dir.entries(dir).each do |file|
                path = File.join(dir, file)
                if File.directory?(path)
                    load_dir(path)
                elsif file =~ /\.rb$/
                    Kernel.load(File.join(dir, file))
                end
            end
        end
    end

    # The list of directories we're going to search through for facts.
    def search_path
        result = []
        result += $LOAD_PATH.collect { |d| File.join(d, "facter") }
        if ENV.include?("FACTERLIB")
            result += ENV["FACTERLIB"].split(":")
        end

        if defined?(Puppet)
            result << Puppet.settings.value(:factdest)
            result << File.join(Puppet.settings.value(:libdir), "facter")
        end
        result
    end

    def old_stuff
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

    private

    def load_dir(dir)
        return if dir =~ /\/util$/
        Dir.entries(dir).find_all { |f| f =~ /\.rb$/ }.each do |file|
            Kernel.load(File.join(dir, file))
        end
    end

    # Load facts from the environment.  If no name is provided,
    # all will be loaded.
    def load_env(fact = nil)
        # Load from the environment, if possible
        ENV.each do |name, value|
            # Skip anything that doesn't match our regex.
            next unless name =~ /^facter_?(\w+)$/i
            env_name = $1

            # If a fact name was specified, skip anything that doesn't
            # match it.
            next if fact and env_name != fact

            Facter.add($1) do
                setcode { value }
            end

            # Short-cut, if we are only looking for one value.
            break if fact
        end
    end
end
