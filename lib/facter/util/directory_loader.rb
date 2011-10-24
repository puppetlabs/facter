require 'facter/util/parser'

# DirectoryLoader is the main entry point for external fact
# support.
#
# http://links.puppetlabs.com/externalfacts
#
# This class is responsible for the traversal of the external
# facts directory, matching a file to a corresponding
# Facter::Util::Parser object for interpretation.
class Facter::Util::DirectoryLoader
  require 'yaml'

  # A list of extensions to ignore in fact directory.
  SKIP_EXTENSIONS = %w{bak ttl orig}

  # Directory for fact loading
  attr_reader :directory

  # Initialize Facter::Util::DirectoryLoader.
  # 
  # dir - Allows you to override the directory to parse, otherwise it is
  #       automatically obtained from Facter::Util::Config.ext_fact_dir
  def initialize(dir = nil)
    @directory = dir || Facter::Util::Config.ext_fact_dir
  end

  # Return all relevant directory based fact file names.
  def entries
    Dir.entries(directory).find_all{|f| parse?(f) }.sort.map {|f| File.join(directory, f) }
  rescue
    []
  end

  # Load facts from files in fact directory using the relevant parser classes to 
  # parse them.
  def load
    entries.each do |file|
      parser = Facter::Util::Parser.new(file)
      if parser == nil
        next
      end

      data = parser.values
      if data == false
        Facter.warn "Could not interpret fact file #{file}"
      elsif data == {} or data == nil
        Facter.warn "Fact file #{file} was parsed but returned an empty data set"
      else
        data.each { |p,v| Facter.add(p, :value => v) }
      end
    end
  end

  private

  # Parse and trim down the list of files based on extension
  def parse?(file)
    return false if file =~ /^\./
    ext = file.split(".")[-1]
    return false if SKIP_EXTENSIONS.include?(ext)
    true
  end
end
