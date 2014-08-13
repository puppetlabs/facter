#!/usr/bin/env ruby

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
  it 'should be derived from lsbdistrelease and take Y from version X.Y.Z where multiple digits exist' do
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    Facter.stubs(:value).with(:lsbdistrelease).returns('10.20.30')
    Facter.fact(:lsbminordistrelease).value.should == '20'
  end
  it 'should not be present if lsbdistrelease is only X and is missing .Y' do
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    Facter.stubs(:value).with(:lsbdistrelease).returns('6')
    Facter.fact(:lsbminordistrelease).value.should == nil
  end
  it 'should not be present on an unsupported kernel' do
    Facter.fact(:kernel).stubs(:value).returns('NotLinuxOrGNU/kFreeBSD')
    Facter.fact(:lsbminordistrelease).value.should == nil
  end
end
