# frozen_string_literal: true

require 'benchmark'
require './lib/fixed'
require 'stringio'


$iters = 250_000

class Fixed
  def inspect_v1
    if @fractions >= 0
      @fractions.to_s.rjust(19, ?0).insert(-19, ?.)
    else
      "-#{@fractions.abs.to_s.rjust(19, ?0).insert(-19, ?.)}"
    end
  end

  def inspect_v2
    if @fractions >= 0
      @fractions.to_s.rjust(19, ?0).insert(-19, ?.)
    else
      @fractions.abs.to_s.rjust(19, ?0).insert(-19, ?.).sub!(/^/, ?-)
    end
  end

  def inspect_v3
    if @fractions >= 0
      @fractions.to_s.rjust(19, ?0).sub!(/.{18}$/, ',\1')
    else
      "-#{@fractions.abs.to_s.rjust(19, ?0).sub!(/.{18}$/, ',\1')}"
    end
 end

  def inspect_v4
    if @fractions >= 0
      @fractions.to_s.rjust(19, ?0).reverse.sub!(/^.{18}/, '\0,').reverse
    else
      @fractions.abs.to_s.rjust(19, ?0).reverse.sub!(/^(.{18}).(.*)$/, '\1,\2-').reverse
    end
  end

  def inspect_v5
    ((@fractions < 0 ? '%020d' : '%019d') % @fractions).insert(-19, ?.)
  end

  def inspect_v6
    str = @fractions.to_s
    len = str.length
    if len > 18
      b = StringIO.new.binmode
      b.write(str[0, -19])
      b.putc ?.
      b.write(str[-19, -1])
      b.string
    else
      b = StringIO.new.binmode
      b.putc ?0
      b.putc ?.
      b.write ?0 * (18 - len)
      b.write str
      b.string
    end
  end

  def inspect_v7
    if @fractions >= 0
      @fractions.to_s.rjust(19, ?0).insert(-19, ?.)
    else
      "-#{@fractions.to_s[1..-1].rjust(19, ?0).insert(-19, ?.)}"
    end
  end
end

Benchmark.bm(32) do |bm|

  one = Fixed 1
  data = $iters.times
    .map { Fixed.from_fractions (((rand ** 18) / (0.5 ** 18)) * 10e18).to_i }
    .map { |each| rand > 0.5 ? -each : each }
  # p data.map(&:abs).minmax
  # p 1.0 * data.count(&:zero?) / data.length
  count = 1.0 * data.count { |each| each.abs < one } / data.length
  raise count.to_s unless (0.4..0.6) === count


  vars = {
    inspect_v1: 'n.rjust.insert',
    inspect_v2: 'n.rjust.insert.sub',
    inspect_v3: 'n.rjust.sub',
    inspect_v4: 'n.rjust.reverse.sub.reverse',
    inspect_v5: 'n.%.insert',
    inspect_v6: 'StringIO.read/write/etc...',
    inspect_v7: 'n.[].rjust.insert',
  }

  vars.entries.shuffle.each do |sym, label|
    GC.start
    bm.report(label) { data.map(&sym) }
  end
end
