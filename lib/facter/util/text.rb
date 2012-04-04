require 'facter'

# This class provides methods for outputting various items in Facter to the
# text console.
#
# It includes color support, and handling structured data textual output as
# well.
class Facter::Util::Text
  def initialize
    # Windows color masks
    win_fg_black     = 0x0000
    win_fg_blue      = 0x0001
    win_fg_green     = 0x0002
    win_fg_red       = 0x0004
    win_fg_intensity = 0x0008

    @colors = {
      :black   => {
        :win32 => win_fg_black,
        :ansi  => 0,
      },
      :red     => {
        :win32 => win_fg_red | win_fg_intensity,
        :ansi  => 1,
      },
      :green   => {
        :win32 => win_fg_green | win_fg_intensity,
        :ansi  => 2,
      },
      :yellow  => {
        :win32 => win_fg_red | win_fg_green | win_fg_intensity,
        :ansi  => 3,
      },
      :blue    => {
        :win32 => win_fg_blue | win_fg_intensity,
        :ansi  => 4,
      },
      :magenta => {
        :win32 => win_fg_red | win_fg_blue | win_fg_intensity,
        :ansi  => 5,
      },
      :cyan    => {
        :win32 => win_fg_blue | win_fg_green | win_fg_intensity,
        :ansi  => 6,
      },
      :white   => {
        :win32 => win_fg_blue | win_fg_green|win_fg_red | win_fg_intensity,
        :ansi  => 7,
      },
    }

    # If we are running in windows, pre-grab the existing console attributes
    # and stdhandle for later.
    if is_windows?
      require 'Win32API'

      gsh = Win32API.new('kernel32', 'GetStdHandle', 'L', 'L')
      @win_handle = gsh.call(-11) # -11 being stdout

      gcsbi = Win32API.new('kernel32', 'GetConsoleScreenBufferInfo', 'LP', 'I')
      lpBuffer = ' ' * 22
      gcsbi.call(@win_handle, lpBuffer)
      info = lpBuffer.unpack('SSSSSssssSS')

      # Console attributes are in the 5th element of the unpacked data
      @win_existing_console_attributes = info[4]

      @stdhandle = Win32API.new('kernel32', 'GetStdHandle', 'L', 'L').call(-11)
    end
  end

  # This method accepts a foreground color attribute from 0-15 and will change
  # the current Windows console accordingly, preserving any other attributes
  # (this includes background color).
  def win_set_fg_color(attribute)
    # Get current background color
    existing_attribute_mask = @win_existing_console_attributes & 0xFFF0

    scta = Win32API.new('kernel32', 'SetConsoleTextAttribute', 'LL', 'I')
    scta.call(@stdhandle, attribute | existing_attribute_mask)
  end

  # This outputs text using the default foreground color scheme.
  def print_default(text)
    if is_windows? and color?
      win_set_fg_color(@win_existing_console_attributes)
    elsif color?
      print "\e[0m"
    end
    print text
  end

  # This method_missing handler deals with outputting colored text in an OS
  # independant way. It dynamically routes a series of methods in the form:
  #
  #     print_<color>
  #
  # Color being one of: black, green, blue, red, yellow, magenta, cyan, white
  def method_missing(meth, *args, &block)
    if meth.to_s.index("print_") == 0 \
      and @colors.include?(color = meth.to_s.sub(/^print_/, '').to_sym)

      # Change color first
      if is_windows? and color?
        win_set_fg_color(@colors[color][:win32])
      elsif color?
        print "\e[3#{@colors[color][:ansi]}m"
      end

      # Print the output
      print args[0]

      # Now reset the color to default
      if is_windows? and color?
        win_set_fg_color(@win_existing_console_attributes)
      elsif color?
        print "\e[0m"
      end
    else
      super
    end
  end

  # This provides a wrapper around pretty_output which outputs the top level
  # keys as puppet-style variables. For example:
  #
  #     $key1 = value
  #     $key2 = [
  #       'value1',
  #       'value2',
  #     ]
  #
  def toplevel_output(data)
    t = Facter::Util::Text.new

    # Line up equals signs
    size_ordered = data.keys.sort_by {|x| x.length}
    max_var_length = size_ordered[-1].length

    data.sort.each do |e|
      k,v = e
      print_yellow("$#{k}")
      indent(max_var_length - k.length, " ")
      print_default(" = ")
      pretty_output(v)
    end
  end

  # This method returns formatted output (with color where applicable) from
  # basic types (hashes, arrays, strings, booleans and numbers).
  def pretty_output(data, indent = 0)
    case data
    when Hash
      print_magenta("{\n")
      indent = indent+1
      data.sort.each do |e|
        k,v = e
        indent(indent)
        print_green("\"#{k}\"")
        print_default " => "
        case v
        when String,TrueClass,FalseClass,Numeric
          pretty_output(v, indent)
        when Hash,Array
          pretty_output(v, indent)
        end
      end
      indent(indent-1)
      print_magenta("}")
      print_default("#{tc(indent-1)}\n")
    when Array
      print_magenta("[\n")
      indent = indent+1
      data.each do |e|
        indent(indent)
        case e
        when String,TrueClass,FalseClass,Numeric
          pretty_output(e, indent)
        when Hash,Array
          pretty_output(e, indent)
        end
      end
      indent(indent-1)
      print_magenta("]")
      print_default("#{tc(indent-1)}\n")
    when TrueClass,FalseClass,Numeric
      print_cyan("#{data}")
      print_default("#{tc(indent)}\n")
    when String
      print_green("\"#{data}\"")
      print_default("#{tc(indent)}\n")
    end
  end

  private

  # Returns true if color is supported
  def color?
    Facter.color?
  end

  # Returns true if windows
  def is_windows?
    Facter::Util::Config.is_windows?
  end

  # Provide a trailing comma if there is an indent, implying this is not
  # following the final closing brace/bracket/etc.
  def tc(indent)
    indent > 0 ? "," : ""
  end

  # Return a series of space characters based on a provided indent size and
  # the number of indents required.
  def indent(num, indent = "  ")
    num.times { $stdout.write(indent) }
  end
end
