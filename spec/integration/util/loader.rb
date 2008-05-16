#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'facter/util/loader'

begin
    require 'puppet'
rescue LoadError
    # Oh well, no Puppet :/
end

describe Facter::Util::Loader do
    if defined?(Puppet)
        describe "when the Puppet libraries are loaded" do
            before { @loader = Facter::Util::Loader.new }
            it "should include the factdest setting" do
                @loader.search_path.should be_include(Puppet.settings.value(:factdest))
            end

            it "should include the facter subdirectory of the libdir setting" do
                @loader.search_path.should be_include(File.join(Puppet.settings.value(:libdir), "facter"))
            end
        end
    end
end
