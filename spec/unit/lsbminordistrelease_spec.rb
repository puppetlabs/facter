#!/usr/bin/env ruby
#
# Copyright (C) 2013 Garrett Honeycutt <code@garretthoneycutt.com>
#
require 'spec_helper'
require 'facter'

describe 'lsbminordistrelease fact' do
  def stub_version(ver)
    Facter.fact(:lsbdistrelease).stubs(:value).returns(ver)
    Facter.collection.internal_loader.load(:lsbminordistrelease)
  end
  context 'lsbdistrelease is defined' do
    it 'is 4 when lsbdistrelease is 6.4' do
      stub_version('6.4')
      Facter.fact(:lsbminordistrelease).value.should == '4'
    end

    it 'is 4 when lsbdistrelease is 6.4.1' do
      stub_version('6.4.1')
      Facter.fact(:lsbminordistrelease).value.should == '4'
    end

    it 'is 14 when lsbdistrelease is 6.14.1' do
      stub_version('6.14.1')
      Facter.fact(:lsbminordistrelease).value.should == '14'
    end
  end

  context 'lsbdistrelease is not defined' do
    it 'is not defined when lsbminordistrelease is false' do
      stub_version(false)
      Facter.fact(:lsbminordistrelease).value.should be_nil
    end
    it 'is not defined when lsbminordistrelease is nil' do
      stub_version(nil)
      Facter.fact(:lsbminordistrelease).value.should be_nil
    end
  end
end
