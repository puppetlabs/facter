#!/usr/bin/env ruby
#
# Copyright (C) 2013 Garrett Honeycutt <code@garretthoneycutt.com>
#
require 'spec_helper'
require 'facter'

describe 'LSB distribution minor release fact' do
  it 'should be derived from lsbdistrelease and take Y from version X.Y' do
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    Facter.stubs(:value).with(:lsbdistrelease).returns('6.4')
    Facter.fact(:lsbminordistrelease).value.should == '4'
  end
  it 'should be derived from lsbdistrelease and take Y from version X.Y.Z' do
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    Facter.stubs(:value).with(:lsbdistrelease).returns('6.4.1')
    Facter.fact(:lsbminordistrelease).value.should == '4'
  end
  it 'should not be present on an unsupported kernel' do
    Facter.fact(:kernel).stubs(:value).returns('NotLinuxOrGNU/kFreeBSD')
    Facter.fact(:lsbminordistrelease).value.should == nil
  end
end
