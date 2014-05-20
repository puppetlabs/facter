require 'spec_helper'

shared_context "enumeration" do

  let(:enumeration_helper) {
    helper = lambda do |name, value, callbacks|
      if value.is_a? String
        callbacks[:string].call name, value
      elsif value.is_a? Integer
        callbacks[:integer].call name, value
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        callbacks[:boolean].call name, (if value then 1 else 0 end)
      elsif value.is_a? Array
        callbacks[:array_start].call name
        value.each do |child|
          helper.call '', child, callbacks
        end
        callbacks[:array_end].call
      elsif value.is_a? Hash
        callbacks[:map_start].call name
        value.each do |k, v|
          helper.call k, v, callbacks
        end
        callbacks[:map_end].call
      else
        raise 'Unexpected value type.'
      end
    end
  }

  def enumerate(facts)
    CFacter::FacterLib.stubs(:enumerate_facts).with do |*args|
      facts.each do |k, v|
        enumeration_helper.call k, v, *args
      end
    end
    CFacter.to_hash.should eq facts
    CFacter::FacterLib.unstub :enumerate_facts
  end
end

describe CFacter do

  it "provides a version" do
    CFacter.version.should_not be_nil
  end

  it "should return an empty hash initially" do
    CFacter.to_hash.should be_empty
  end

  it "should return nil for a value initially" do
    CFacter.value('cfacterversion').should be_nil
  end

  it "contains a matching cfacter version" do
    CFacter.loadfacts
    version = CFacter.value('cfacterversion')
    version.should eq CFacter.version
    version.should eq CFacter::FACTER_VERSION
  end

  it "should load facts" do
    CFacter.loadfacts
    CFacter.to_hash.should_not be_empty
  end

  it "should clear facts" do
    CFacter.loadfacts
    CFacter.to_hash.should_not be_empty
    CFacter.clear
    CFacter.to_hash.should be_empty
  end

  describe "should enumerate" do
    include_context "enumeration"

    it "string facts" do
      enumerate({
        'fact1' => 'value1',
        'fact2' => 'value2',
        'fact3' => 'value3'
      })
    end

    it "integer facts" do
      enumerate({
        'fact1' => 1,
        'fact2' => 2,
        'fact3' => 3
      })
    end

    it "boolean facts" do
      enumerate({
        'fact1' => true,
        'fact2' => false
      })
    end

    it "array facts" do
      enumerate({
        'fact1' => [ 'one', 2, 'three' ],
        'fact2' => [ 'one', ['two', 3] ],
        'fact3' => []
      })
    end

    it "hash facts" do
      enumerate({
        'fact1' => { 'array' => [ 'one', 2, 'three' ], 'string' => 'world', 'integer' => 5 },
        'fact2' => { 'hash' => { 'foo' => 'bar', 'integer' => 1 } },
        'fact3' => { 'array' => [ { 'foo' => 'bar' }] }
      })
    end
  end

end
