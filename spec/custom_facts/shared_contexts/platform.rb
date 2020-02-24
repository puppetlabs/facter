# Contexts for stubbing platforms
# In a describe or context block, adding :as_platform => :windows or
# :as_platform => :posix will stub the relevant facter config, as well as
# the behavior of Ruby's filesystem methods by changing File::ALT_SEPARATOR.
#
#
#
shared_context 'windows', as_platform: :windows do
  before do
    allow(LegacyFacter).to receive(:value).and_return('Windows')
    allow(LegacyFacter::Util::Config).to receive(:windows?).and_return true
  end

  around do |example|
    file_alt_separator = File::ALT_SEPARATOR
    file_path_separator = File::PATH_SEPARATOR
    # prevent Ruby from warning about changing a constant
    with_verbose_disabled do
      File::ALT_SEPARATOR = '\\'.freeze
      File::PATH_SEPARATOR = ';'.freeze
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

shared_context 'posix', as_platform: :posix do
  before do
    LegacyFacter::Util::Config.stubs(:windows?).returns false
  end

  around do |example|
    file_alt_separator = File::ALT_SEPARATOR
    file_path_separator = File::PATH_SEPARATOR
    # prevent Ruby from warning about changing a constant
    with_verbose_disabled do
      File::ALT_SEPARATOR = nil
      File::PATH_SEPARATOR = ':'.freeze
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
