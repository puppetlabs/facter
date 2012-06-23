# A composite loader that allows for more than one 
# default directory loader

require 'facter/util/directory_loader'

class Facter::Util::CompositeLoader 
  
  def initialize(dir_loaders) 
    @directory_loaders = []
    @directory_loaders[0] = dir_loaders[0]
    @directory_loaders[1] = dir_loaders[1]
  end 
  
  def load 
    @directory_loaders[0].load 
    @directory_loaders[1].load 
  end 
end 
  
  