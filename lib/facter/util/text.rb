require 'facter'
require 'facter/util/colors'

# This class provides methods for outputting various items in Facter to the
# text console.
#
# It includes color support, and handling structured data textual output as
# well.
class Facter::Util::Text
  include Facter::Util::Colors

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
      print(colorize(:fact_name, "$#{k}"))
      indent(max_var_length - k.length, " ")
      print(colorize(:equals, " = "))
      pretty_output(v)
    end
  end

  # This method returns formatted output (with color where applicable) from
  # basic types (hashes, arrays, strings, booleans and numbers).
  def pretty_output(data, indent = 0)
    case data
    when Hash
      print(colorize(:curly_braces, "{"),"\n")
      indent = indent+1
      data.sort.each do |e|
        k,v = e
        indent(indent)
        print(colorize(:strings, "\"#{k}\""))
        print(colorize(:hash_arrows, " => "))
        case v
        when String,TrueClass,FalseClass,Numeric
          pretty_output(v, indent)
        when Hash,Array
          pretty_output(v, indent)
        end
      end
      indent(indent-1)
      print(colorize(:curly_braces, "}"))
      print(colorize(:commas, tc(indent-1)), "\n")
    when Array
      print(colorize(:square_braces, "["), "\n")
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
      print(colorize(:square_braces, "]"))
      print(colorize(:commas, tc(indent-1)), "\n")
    when TrueClass,FalseClass
      print(colorize(:booleans, data.to_s))
      print(colorize(:commas, tc(indent)), "\n")
    when Numeric
      print(colorize(:numbers, data.to_s))
      print(colorize(:commas, tc(indent)), "\n")
    when String
      print(colorize(:strings, "\"#{data}\""))
      print(colorize(:commas, tc(indent)), "\n")
    end
  end

  # Running this function will cause output to be paged through your local
  # PAGER application. This can be used to make an application behave just like
  # git.
  def run_pager
    return if PLATFORM =~ /win32/
    Facter.pager(true)
    return unless STDOUT.tty?

    read, write = IO.pipe

    unless Kernel.fork # Child process
      STDOUT.reopen(write)
      STDERR.reopen(write) if STDERR.tty?
      read.close
      write.close
      return
    end

    # Parent process, become pager
    STDIN.reopen(read)
    read.close
    write.close

    ENV['LESS'] = 'FSRX' # Don't page if the input is short enough

    Kernel.select [STDIN] # Wait until we have input before we start the pager
    pager = ENV['PAGER'] || 'less'
    exec pager rescue exec "/bin/sh", "-c", pager
  end

  private

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
