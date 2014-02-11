require 'spec_helper'
require 'facter/core/execution'

describe Facter::Core::Execution do
  subject { described_class}
  let(:impl) { described_class.impl }

  it "delegates #search_paths to the implementation" do
    impl.expects(:search_paths)
    subject.search_paths
  end

  it "delegates #which to the implementation" do
    impl.expects(:which).with('waffles')
    subject.which('waffles')
  end

  it "delegates #absolute_path? to the implementation" do
    impl.expects(:absolute_path?).with('waffles', nil)
    subject.absolute_path?('waffles')
  end

  it "delegates #absolute_path? with an optional platform to the implementation" do
    impl.expects(:absolute_path?).with('waffles', :windows)
    subject.absolute_path?('waffles', :windows)
  end

  it "delegates #expand_command to the implementation" do
    impl.expects(:expand_command).with('waffles')
    subject.expand_command('waffles')
  end

  it "delegates #with_env to the implementation" do
    impl.expects(:with_env).with('HOME' => '/home/waffles')
    subject.with_env('HOME' => '/home/waffles')
  end

  it "delegates #exec to the implementation" do
    impl.expects(:exec).with('waffles')
    subject.exec('waffles')
  end
end
