require 'facter'
require 'pathname'
require 'facter/util/directory_loader'

# Load facts on demand.
class Facter::Util::Loader

  def initialize
    @loaded = []
  end

  # Load all resolutions for a single fact.
  #
  # @api public
  # @param name [Symbol]
  def load(fact)
    # Now load from the search path
    shortname = fact.to_s.downcase
    load_env(shortname)

    filename = shortname + ".rb"

    paths = search_path
    unless paths.nil?
      paths.each do |dir|
        # Load individual files
        file = File.join(dir, filename)

        load_file(file) if File.file?(file)
      end
    end
  end

  # Load all facts from all directories.
  #
  # @api public
  def load_all
    return if defined?(@loaded_all)

    load_env

    paths = search_path
    unless paths.nil?
      paths.each do |dir|
        # dir is already an absolute path
        Dir.glob(File.join(dir, '*.rb')).each do |dirent|
          path = File.join(dir, dirent)
          # exclude dirs that end with .rb
          load_file(path) if File.file?(path)
        end
      end
    end

    @loaded_all = true
  end

  # List of directories to search for fact files.
  #
  # Search paths are gathered from the following sources:
  #
  # 1. $LOAD_PATH entries are expanded to absolute paths
  # 2. ENV['FACTERLIB'] is split and used verbatim
  # 3. Entries from Facter::search_path are used verbatim
  #
  # A warning will be generated for any path(s) from Facter::search_path that
  # are not an absolute path to an existing directory.
  #
  # @api public
  # @return [Array<String>]
  def search_path
    result = []
    result += $LOAD_PATH.map { |path| File.expand_path('facter', path) }

    if ENV.include?('FACTERLIB')
      ENV['FACTERLIB'].split(File::PATH_SEPARATOR).each do |path|
        result << path
      end
    end

    # silently ignore bad search paths from $LOAD_PATH and FACTERLIB
    result = result.select { |path| valid_search_path?(path) }

    # This allows others to register additional paths we should search.
    # We are assuming that these are already absolute paths.
    result += Facter.search_path.select do |path|
      valid = valid_search_path?(path)
      Facter.warn "Excluding #{path} from search path. Fact file paths must be an absolute directory" unless valid
      valid
    end

    # remove any dups
    result.uniq
  end

  private

  # Validate that a path string is a valid to use for loading loading fact .rb
  # files from.  The path must both be absolute and a directory.
  #
  # @api private
  # @param path [String]
  # @return [Boolean]
  def valid_search_path?(path)
    unless File.directory?(path) and Pathname.new(path).absolute?
      return false
    end

    true
  end

  # Load a file and record is paths to prevent duplicate loads.
  #
  # @api private
  # @params file [String] The *absolute path* to the file to load
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
      Facter.warn "Error loading fact #{file} #{detail}"
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
