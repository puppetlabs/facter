require 'facter'

# Load facts on demand.
class Facter::Util::Loader

    def initialize
      @loaded = []
    end

    # Load all resolutions for a single fact.
    def load(fact)
        # Now load from the search path
        shortname = fact.to_s.downcase
        load_env(shortname)

        filename = shortname + ".rb"
        search_path.each do |dir|
            # Load individual files
            file = File.join(dir, filename)

            load_file(file) if FileTest.exist?(file)

            # And load any directories matching the name
            factdir = File.join(dir, shortname)
            load_dir(factdir) if FileTest.directory?(factdir)
        end
    end

    # Load all facts from all directories.
    def load_all
        return if defined?(@loaded_all)

        load_env

        search_path.each do |dir|
            next unless FileTest.directory?(dir)

            Dir.entries(dir).sort.each do |file|
                path = File.join(dir, file)
                if File.directory?(path)
                    load_dir(path)
                elsif file =~ /\.rb$/
                    load_file(File.join(dir, file))
                end
            end
        end

        @loaded_all = true
    end

    # The list of directories we're going to search through for facts.
    def search_path
        result = []
        result += $LOAD_PATH.collect { |d| File.join(d, "facter") }
        if ENV.include?("FACTERLIB")
            result += ENV["FACTERLIB"].split(":")
        end

        # This allows others to register additional paths we should search.
        result += Facter.search_path

        result
    end

    private

    def load_dir(dir)
        return if dir =~ /\/\.+$/ or dir =~ /\/util$/ or dir =~ /\/lib$/

        Dir.entries(dir).find_all { |f| f =~ /\.rb$/ }.sort.each do |file|
            load_file(File.join(dir, file))
        end
    end

    def load_file(file)
        return if @loaded.include? file
        # We have to specify Kernel.load, because we have a load method.
        begin
            # Store the file path so we don't try to reload it
            @loaded << file
            Kernel.load(file)
        rescue ScriptError => detail
            # Don't store the path if the file can't be loaded
            # in case it's loadable later on.
            @loaded.delete(file)
            warn "Error loading fact #{file} #{detail}"
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
                has_weight 1_000_000
                setcode { value }
            end

            # Short-cut, if we are only looking for one value.
            break if fact
        end
    end
end
