# frozen_string_literal: true

require 'benchmark'
require './lib/fixed'
require 'stringio'


$iters = 250_000

def string_as_fractions_v1(str)
  str =~ /\A(-?\d+)(?:\.(\d{1,18}))?\Z/
  whole = $1
  raise "expected number with up to 18 decimal places, got #{str.inspect}" unless whole
  "#{whole}#{$2}".ljust(whole.length + 18, ?0).to_i
end

def string_as_fractions_v2(str)
  str =~ /\A(-?\d+)(?:\.(\d{1,18}))?\Z/
  whole, decimals = $1, $2
  raise "expected number with up to 18 decimal places, got #{str.inspect}" unless whole
  if decimals and decimals.length == 18
    "#{whole}#{decimals}".to_i
  elsif decimals
    "#{whole}#{decimals}".to_i * (10 ** (18 - decimals.length))
  else
    whole.to_i * 1000000000000000000
  end
end

def string_as_fractions_v3(str)
  str =~ /\A(-?\d+)(?:\.(\d{1,18}))?\Z/
  whole, decimals = $1, $2
  raise "expected number with up to 18 decimal places, got #{str.inspect}" unless whole
  if decimals && decimals.length == 18
    "#{whole}#{decimals}".to_i
  elsif decimals
    "#{whole}#{decimals}".ljust(whole.length + 18, ?0).to_i
  else
    whole.to_i * 1000000000000000000
  end
end

def string_as_fractions_v4(str)
  str =~ /\A(-?\d+)(?:\.(\d{1,18}))?\Z/
  whole, decimals = $1, $2
  raise "expected number with up to 18 decimal places, got #{str.inspect}" unless whole
  return whole.to_i * 1000000000000000000 unless decimals
  return "#{whole}#{decimals}".to_i if decimals.length == 18

  "#{whole}#{decimals}".ljust(whole.length + 18, ?0).to_i
end

Benchmark.bm(32) do |bm|

  one = Fixed 1
  data = $iters.times
    .map {
      case rand 3
      when 0
        "#{?- if rand > 0.5}#{rand(1000000)}.#{18.times.map { rand 10 }.join}"
      when 1
        "#{?- if rand > 0.5}#{rand(1000000)}"
      else
        "#{?- if rand > 0.5}#{rand(1000000)}.#{(rand(12).succ).times.map { rand 10 }.join}"
      end
    }

  bm.report('n.concat.ljust.to_i') { data.each { |str| string_as_fractions_v1 str } }
  GC.start
  bm.report('n.concat.to_i.**.*') { data.map { |str| string_as_fractions_v2 str } }
  GC.start
  bm.report('n.concat.ljust.to_i (2)') { data.each { |str| string_as_fractions_v3 str } }
  GC.start
  bm.report('n.concat.ljust.to_i (3)') { data.each { |str| string_as_fractions_v4 str } }
end
