# A composite loader that allows for more than one
# default directory loader

class Facter::Util::CompositeLoader
  def initialize(loaders)
    @loaders = loaders
  end

  def load(collection)
    @loaders.each { |loader| loader.load(collection) }
  end
end
