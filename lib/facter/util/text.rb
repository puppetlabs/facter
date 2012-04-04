require 'facter'

# This class provides methods for outputting various items in Facter to the
# text console.
#
# It includes color support, and handling structured data textual output as
# well.
class Facter::Util::Text
  def initialize
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

    # Windows color masks
    win_fg_black     = 0x0000
    win_fg_blue      = 0x0001
    win_fg_green     = 0x0002
    win_fg_red       = 0x0004
    win_fg_intensity = 0x0008

    @colors = {
      :black   => {
        :win32 => win_fg_black,
        :ansi  => "\e[30m",
      },
      :red     => {
        :win32 => win_fg_red,
        :ansi  => "\e[31m",
      },
      :green   => {
        :win32 => win_fg_green,
        :ansi  => "\e[32m",
      },
      :yellow  => {
        :win32 => win_fg_red | win_fg_green,
        :ansi  => "\e[33m",
      },
      :blue    => {
        :win32 => win_fg_blue,
        :ansi  => "\e[34m",
      },
      :magenta => {
        :win32 => win_fg_red | win_fg_blue,
        :ansi  => "\e[35m",
      },
      :cyan    => {
        :win32 => win_fg_blue | win_fg_green,
        :ansi  => "\e[36m",
      },
      :white   => {
        :win32 => win_fg_blue | win_fg_green | win_fg_red,
        :ansi  => "\e[37m",
      },
    }

    # Now add the bright colors
    @colors.each do |color, settings|
      @colors[("bright_" + color.to_s).to_sym] = {
        :win32 => settings[:win32] | win_fg_intensity,
        :ansi  => "\e[1m" + settings[:ansi],
      }
    end

    # Define the default color
    @colors[:default] = {
      :win32 => @win_existing_console_attributes,
      :ansi  => "\e[0m",
    }

    # Lets define some color schemes
    @colors[:fact_name]     = is_windows? ? @colors[:bright_yellow] : @colors[:yellow]
    @colors[:curly_braces]  = is_windows? ? @colors[:bright_magenta] : @colors[:magenta]
    @colors[:square_braces] = is_windows? ? @colors[:bright_magenta] : @colors[:magenta]
    @colors[:strings]       = is_windows? ? @colors[:bright_green] : @colors[:green]
    @colors[:booleans]      = is_windows? ? @colors[:bright_cyan] : @colors[:cyan]
    @colors[:numbers]       = is_windows? ? @colors[:bright_cyan] : @colors[:cyan]
    @colors[:commas]        = @colors[:default]
    @colors[:equals]        = @colors[:default]
    @colors[:hash_arrows]   = @colors[:default]
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

  # This method deals with outputting colored text in an OS independant way.
  #
  # It works just like Kernel#print but accepts an initial parameter: color
  #
  # Color accepts a symbol that must be one of:
  #
  # * Primary colors: black, green, blue, red, yellow, magenta, cyan, white
  # * Special: default (that is the default foreground color)
  #
  # The second argument to color_print is the text you wish to be printed to
  # the screen after the color change. After the text is printed, the color
  # will be reverted to default so subsequent prints & puts will use only the
  # default color.
  def color_print(color, *text)
    if @colors.include?(color)

      # Change color first
      if is_windows? and color?
        win_set_fg_color(@colors[color][:win32])
      elsif color?
        print @colors[color][:ansi]
      end

      # Print the output
      print text

      # Now reset the color to default
      if is_windows? and color?
        win_set_fg_color(@win_existing_console_attributes)
      elsif color?
        print "\e[0m"
      end
    else
      raise "Unknown color type #{color}"
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
      color_print(:fact_name, "$#{k}")
      indent(max_var_length - k.length, " ")
      color_print(:equals, " = ")
      pretty_output(v)
    end
  end

  # This method returns formatted output (with color where applicable) from
  # basic types (hashes, arrays, strings, booleans and numbers).
  def pretty_output(data, indent = 0)
    case data
    when Hash
      color_print(:curly_braces, "{\n")
      indent = indent+1
      data.sort.each do |e|
        k,v = e
        indent(indent)
        color_print(:strings, "\"#{k}\"")
        color_print(:hash_arrows, " => ")
        case v
        when String,TrueClass,FalseClass,Numeric
          pretty_output(v, indent)
        when Hash,Array
          pretty_output(v, indent)
        end
      end
      indent(indent-1)
      color_print(:curly_braces, "}")
      color_print(:commas, "#{tc(indent-1)}\n")
    when Array
      color_print(:square_braces, "[\n")
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
      color_print(:square_braces, "]")
      color_print(:commas, "#{tc(indent-1)}\n")
    when TrueClass,FalseClass
      color_print(:booleans, "#{data}")
      color_print(:commas, "#{tc(indent)}\n")
    when Numeric
      color_print(:numbers, "#{data}")
      color_print(:commas, "#{tc(indent)}\n")
    when String
      color_print(:strings, "\"#{data}\"")
      color_print(:commas, "#{tc(indent)}\n")
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
