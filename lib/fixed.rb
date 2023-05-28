# frozen_string_literal: true

require 'fixed/version'


# A number with 18-digit precision.
#
# Fixed-point implementation of numbers with 18-digit precision, which
# avoids issues with floating-point rounding errors and ensures that
# arithmetic operations are performed with full precision. This class is
# useful in situations where it's necessary to represent rational
# numbers with a high degree of precision, such as in scientific or
# financial applications.
#
# Example usage
#
#   a = Fixed(1)
#   b = Fixed(6)
#   ratio = a / b
#   puts ratio.format(18) # => prints 1.666666666666666667
#
#


class Fixed

  include Comparable


  #------- constructors ---------------------------------------------

  private_class_method :new

  def initialize(fractions)
    raise unless Integer === fractions
    @fractions = fractions
    freeze
  end

  def self.parse(str)
    new string_as_fractions(str)
  end

  def self.from_number(number)
    new number_as_fractions(number)
  end

  def self.from_fractions(fractions)
    new fractions
  end

  def self.smallest
    new 1
  end

  def self.zero
    new 0
  end


  #------- arithmetics ----------------------------------------------

  def +(number)
    make(self.fractions + number.fractions)
  end

  def -(number)
    make(self.fractions - number.fractions)
  end

  def *(number)
    make(division_with_rounding(
      self.fractions * number.fractions,
      1000000000000000000,
    ))
  end

  def /(number)
    make(division_with_rounding(
      1000000000000000000 * self.fractions,
      number.fractions,
    ))
  end

  def -@
    make(-self.fractions)
  end

  def abs
    make(self.fractions.abs)
  end

  def split(*numbers)
    ratios = numbers.map(&:to_fixed)
    raise ArgumentError if ratios.any?(&:negative?)
    raise ArgumentError if ratios.all?(&:zero?)

    # This method ensures that the calculated portions add up to the original
    # value and that no eps are lost due to rounding errors or other issues.

    remainder = ratios.reduce(:+)
    number = self

    ratios.map do |ratio|
      next Fixed.zero if remainder.zero?

      part = make(division_with_rounding(
        number.fractions * ratio.fractions,
        remainder.fractions,
      ))
      remainder -= ratio
      number -= part
      part
    end
  end


  # ------- comparing -----------------------------------------------

  def <=>(number)
    return nil unless Fixed === number
    self.fractions <=> number.fractions
  end

  def ==(number)
    Fixed === number && self.fractions == number.fractions
  end

  def negative?
    @fractions < 0
  end

  def positive?
    @fractions > 0
  end

  def zero?
    @fractions == 0
  end


  # ------- printing ------------------------------------------------

  def inspect
    if @fractions >= 0
      @fractions.to_s.rjust(19, ?0).insert(-19, ?.)
    else
      "-#{@fractions.abs.to_s.rjust(19, ?0).insert(-19, ?.)}"
    end
  end

  def to_s(precision = 8)
    format(precision)
  end

  def format(precision = 8)
    raise "expected 1..18, got #{precision.inspect}" unless (0..18) === precision

    rounded_fractions = division_with_rounding(@fractions, 10 ** (18 - precision))
    str = rounded_fractions.abs.to_s.rjust(precision + 1, ?0)
    str.insert(-1 - precision, ?.) if precision > 0
    "#{?- if @fractions < 0}#{str}#{?* if @fractions != 0 && str =~ /^[-0\.]*$/}"
  end


  # ------- serialization -------------------------------------------

  def to_json(state)
    inspect.to_json(state)
  end

  def self.from_snapshot(arg, options)
    String === arg ? self.parse(arg) : arg
  end


  # ------- helpers -------------------------------------------------

  attr_reader :fractions

  def to_fixed
    self
  end

  protected

  def make(new_fractions)
    Fixed.from_fractions new_fractions
  end

  def self.string_as_fractions(str)

    # NOTE: this code has been optimized to balance execution time versus
    # creation of unnecessary objects and string copies. We found calling
    # String#match to be slower than calling Regexp#=~ and using special
    # variables, and we found caching the special variables to be faster
    # (apparently new substrings are created upon each access), and also
    # we found string concatenation and converting integer only once to
    # be faster than two conversions and arithmetic operations.

    str =~ /\A(-?\d+)(?:\.(\d{1,18}))?\Z/
    whole, decimals = $1, $2
    raise "expected valid string representation, got #{str.inspect}" unless whole

    if decimals == nil
      whole.to_i * 1000000000000000000
    elsif decimals.length == 18
      "#{whole}#{decimals}".to_i
    else
      "#{whole}#{decimals}".ljust(whole.length + 18, ?0).to_i
    end
  end

  def self.number_as_fractions(number)
    case number
    when Float
      # NOTE: Ensures consistency with the visible representation of floats
      # to avoid rounding errors such as 16.50479841 => 1.6504798409999998976

      number.to_s =~ /\A(-?\d+)(?:\.(\d+))(?:e([+-]\d+))?\Z/
      whole, decimals, padding = $1, $2, $3.to_i + 18
      raise "unsupported floating-point value: #{number}" unless whole

      if padding < decimals.length
        "#{whole}#{decimals}"[0..(padding - decimals.length - 1)].to_i
      else
        "#{whole}#{decimals}".ljust(whole.length + padding, ?0).to_i
      end
    else
      Integer number * 1000000000000000000
    end
  end

  private

  def division_with_rounding(numerator, denominator)
    (numerator + (denominator / 2)) / denominator
  end
end

module Kernel
  def Fixed(arg)
    case arg
    when String
      Fixed.parse arg
    when Numeric
      Fixed.from_number arg
    else
      raise ArgumentError
    end
  end
end

class Numeric
  def to_fixed
    Fixed.from_number self
  end
end
