# Contexts for stubbing platforms
# In a describe or context block, adding :as_platform => :windows or
# :as_platform => :posix will stub the relevant facter config, as well as
# the behavior of Ruby's filesystem methods by changing File::ALT_SEPARATOR.
#
#
#
shared_context "windows", :as_platform => :windows do
  before :each do
    Facter.fact(:operatingsystem).stubs(:value).returns('Windows')
    Facter::Util::Config.stubs(:is_windows?).returns true
  end

  around do |example|
    file_alt_separator = File::ALT_SEPARATOR
    file_path_separator = File::PATH_SEPARATOR
    # prevent Ruby from warning about changing a constant
    with_verbose_disabled do
      File::ALT_SEPARATOR = '\\'
      File::PATH_SEPARATOR = ';'
    end
    begin
      example.run
    ensure
      with_verbose_disabled do
        File::ALT_SEPARATOR = file_alt_separator
        File::PATH_SEPARATOR = file_path_separator
      end
    end
  end
end

shared_context "posix", :as_platform => :posix do
  before :each do
    Facter::Util::Config.stubs(:is_windows?).returns false
  end

  around do |example|
    file_alt_separator = File::ALT_SEPARATOR
    file_path_separator = File::PATH_SEPARATOR
    # prevent Ruby from warning about changing a constant
    with_verbose_disabled do
      File::ALT_SEPARATOR = nil
      File::PATH_SEPARATOR = ':'
    end
    begin
      example.run
    ensure
      with_verbose_disabled do
        File::ALT_SEPARATOR = file_alt_separator
        File::PATH_SEPARATOR = file_path_separator
      end
    end
  end
end
