require 'spec_helper'
require 'facter/util/name'

include Facter::Util::Name

describe '#canonicalize_name' do
  context 'name type handling' do
    it 'should accept Symbol' do
      expect { canonicalize_name(:foo) }.to_not raise_error
    end

    it 'should accept String' do
      expect { canonicalize_name('foo') }.to_not raise_error

    end

    it 'should raise exception for Array' do
      expect { canonicalize_name([:foo]) }.
        to raise_error ArgumentError, /is not a Symbol or a String/
    end

    it 'should raise exception for Boolean' do
      expect { canonicalize_name(true) }.
        to raise_error ArgumentError, /is not a Symbol or a String/
    end

    it 'should raise exception for Hash' do
      expect { canonicalize_name({ :foo => :bar }) }.
        to raise_error ArgumentError, /is not a Symbol or a String/
    end
  end # acceptable types

  context 'Symbol handling' do
    it 'should pass lowercase Symbol' do
      canonicalize_name(:foo).should == :foo
    end

    it 'should normalize uppercase Symbol with warning' do
      Facter.expects(:warn).with('Fact name FOO should be all lowercase.')
      canonicalize_name(:FOO).should == :foo
    end

    it 'should normalize mixedcase Symbol with warning' do
      Facter.expects(:warn).with('Fact name fOo should be all lowercase.')
      canonicalize_name(:fOo).should == :foo
    end
  end # Symbol handling

  context 'String handling' do
    it 'should normalize lowecase String with warning' do
      Facter.expects(:warn).with("Fact name foo should be a Symbol.")
      canonicalize_name('foo').should == :foo
    end

    it 'should normalize uppercase String with warnings' do
      Facter.expects(:warn).with("Fact name FOO should be a Symbol.")
      Facter.expects(:warn).with('Fact name FOO should be all lowercase.')
      canonicalize_name('FOO').should == :foo
    end

    it 'should normalize mixedcase String with warnings' do
      Facter.expects(:warn).with("Fact name fOo should be a Symbol.")
      Facter.expects(:warn).with('Fact name fOo should be all lowercase.')
      canonicalize_name('fOo').should == :foo
    end
  end # String handling
end
