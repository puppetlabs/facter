require 'facter'

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

  def method_missing(meth, *args, &block)
    if @ansi_colors.include?(meth)
      color_num = @ansi_colors[meth]
      return color? ? "\e[3#{color_num}m" : ""
    else
      super
    end
  end

  private

  def color?
    Facter.color?
  end
end
