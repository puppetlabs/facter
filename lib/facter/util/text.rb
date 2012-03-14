require 'facter'

# This class provides methods for outputting various items in Facter to the
# text console.
#
# It includes color support, and handling structured data textual output as
# well.
class Facter::Util::Text
  def initialize
    @ansi_colors = {
      :black   => 0,
      :red     => 1,
      :green   => 2,
      :yellow  => 3,
      :blue    => 4,
      :magenta => 5,
      :cyan    => 6,
      :white   => 7,
    }
  end

  def bright
    color? ? "\e[1m" : ""
  end

  def reset
    color? ? "\e[0m" : ""
  end

  # This method_missing handler deals with outputting ASCII escape characters for
  # terminal colors.
  def method_missing(meth, *args, &block)
    if @ansi_colors.include?(meth)
      color_num = @ansi_colors[meth]
      return color? ? "\e[3#{color_num}m" : ""
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
  def facter_output(data)
    t = Facter::Util::Text.new

    # Line up equals signs
    size_ordered = data.keys.sort_by {|x| x.length}
    max_var_length = size_ordered[-1].length

    data.sort.each do |e|
      k,v = e
      $stdout.write("#{t.yellow}$#{k}#{t.reset}")
      indent(max_var_length - k.length, " ")
      $stdout.write(" = ")
      pretty_output(v)
    end
  end

  # This method returns formatted output (with color where applicable) from
  # basic types (hashes, arrays, strings, booleans and numbers).
  def pretty_output(data, indent = 0)
    t = Facter::Util::Text.new

    case data
    when Hash
      puts "#{t.magenta}{#{t.reset}"
      indent = indent+1
      data.sort.each do |e|
        k,v = e
        indent(indent)
        $stdout.write "#{t.green}\"#{k}\"#{t.reset} => "
        case v
        when String,TrueClass,FalseClass,Numeric
          pretty_output(v, indent)
        when Hash,Array
          pretty_output(v, indent)
        end
      end
      indent(indent-1)
      puts "#{t.magenta}}#{t.reset}#{tc(indent-1)}"
    when Array
      puts "#{t.magenta}[#{t.reset}"
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
      puts "#{t.magenta}]#{t.reset}#{tc(indent-1)}"
    when TrueClass,FalseClass,Numeric
      puts "#{t.cyan}#{data}#{t.reset}#{tc(indent)}"
    when String
      puts "#{t.green}\"#{data}\"#{t.reset}#{tc(indent)}"
    end
  end

  private

  # Returns true if color is supported
  def color?
    Facter.color?
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
