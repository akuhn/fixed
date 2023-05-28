require './lib/fixed'
require 'json'


describe Fixed do

  it "has a version number" do
    expect(Fixed::VERSION).not_to be nil
  end

  it 'represents an 18-digit fraction without loss' do

    num = Fixed '3.141592653589793238'
    expect(num.fractions).to eq 3141592653589793238
    expect(num.inspect).to eq "3.141592653589793238"
    expect(num.format).to eq "3.14159265"
  end

  it 'represents smallest fraction' do

    num = Fixed 1e-18
    expect(num.fractions).to eq 1
    expect(num.inspect).to eq "0.000000000000000001"
    expect(num.format).to eq "0.00000000*"
    expect(num).to eq Fixed.smallest
  end

  it 'represents one' do

    num = Fixed 1
    expect(num.fractions).to eq 1e18
    expect(num.inspect).to eq "1.000000000000000000"
    expect(num.format).to eq "1.00000000"
    expect(num.positive?).to be true
  end

  it 'represents zero' do

    num = Fixed 0
    expect(num.fractions).to eq 0
    expect(num.inspect).to eq "0.000000000000000000"
    expect(num.format).to eq "0.00000000"
    expect(num).to eq Fixed.zero
    expect(num.zero?).to be true
  end

  it 'represents negative numbers' do

    num = Fixed -17.5
    expect(num.fractions).to eq -17500000000000000000
    expect(num.inspect).to eq "-17.500000000000000000"
    expect(num.format).to eq "-17.50000000"
    expect(num.negative?).to be true
  end

  describe 'creating new instances' do

    it 'converts a string to fixed-point number' do
      expect((Fixed '23').inspect).to eq "23.000000000000000000"
      expect((Fixed '2.65').inspect).to eq "2.650000000000000000"
      expect((Fixed '0.03').inspect).to eq "0.030000000000000000"
      expect((Fixed '0.000000000000000001')).to eq Fixed.smallest
      expect((Fixed '0').inspect).to eq "0.000000000000000000"
    end

    it 'converts a string to negative fixed-point number' do
      expect((Fixed '-1').fractions).to eq -1000000000000000000
      expect((Fixed '-1.8').fractions).to eq -1800000000000000000
      expect((Fixed '-0.8').fractions).to eq -800000000000000000
    end

    it 'avoids parsing strings with leading zeros as octal numbers' do
      expect((Fixed '0031').format).to eq "31.00000000" # and not 25.00000000
      expect((Fixed '0.0031').format).to eq "0.00310000" # and not 0.00250000
    end

    it 'ensures consistency with the visible representation of floats' do
      expect((Fixed 2.65).inspect).to eq "2.650000000000000000"
      expect((Fixed 16.50479841).inspect).to eq "16.504798410000000000"
      expect((Fixed 1e18).inspect).to eq "1000000000000000000.000000000000000000"
      expect((Fixed 1e-18).inspect).to eq "0.000000000000000001"
      expect((Fixed 0).inspect).to eq "0.000000000000000000"
    end

    it 'converts fractions to fixed-point number' do
      pi = Fixed.from_fractions 3141592653589793238
      expect(pi.inspect).to eq "3.141592653589793238"
      one = Fixed.from_fractions 1e18.to_int
      expect(one.inspect).to eq "1.000000000000000000"
      eps = Fixed.from_fractions 1
      expect(eps.inspect).to eq "0.000000000000000001"
    end
  end

  describe 'when doing arithmetic operations' do

    let(:a) { Fixed 3.5 }
    let(:b) { Fixed 2.65 }

    it { expect((a + b).inspect).to eq "6.150000000000000000" }
    it { expect((a - b).inspect).to eq "0.850000000000000000" }
    it { expect((a * b).inspect).to eq "9.275000000000000000" }
    it { expect((a / b).inspect).to eq "1.320754716981132075" }

    it 'returns negated value' do
      expect(-(Fixed  2.65)).to eq (Fixed -2.65)
      expect(-(Fixed -2.65)).to eq (Fixed  2.65)
    end

    it 'returns absolute value' do
      expect((Fixed  2.65).abs).to eq (Fixed 2.65)
      expect((Fixed -2.65).abs).to eq (Fixed 2.65)
    end
  end

  describe 'when dividing numbers' do

    it 'rounds result up towards the nearest epsilon' do
      expect(((Fixed 1) / (Fixed 6)).inspect).to eq "0.166666666666666667"
      expect(((Fixed 1) / (Fixed 3)).inspect).to eq "0.333333333333333333"
      expect(((Fixed 4) / (Fixed 7)).inspect).to eq "0.571428571428571429"
      expect(((Fixed 12) / (Fixed 17)).inspect).to eq "0.705882352941176471"
    end

    it 'rounds remainder of half-an-epsilon towards ceiling' do
      expect((Fixed.from_fractions 10) / Fixed(4)).to eq (Fixed.from_fractions 3)
      expect((Fixed.from_fractions 10) / Fixed(-4)).to eq (Fixed.from_fractions -2)
      expect((Fixed.from_fractions -10) / Fixed(4)).to eq (Fixed.from_fractions -2)
      expect((Fixed.from_fractions -10) / Fixed(-4)).to eq (Fixed.from_fractions 3)
    end

    it 'passes example from Float#truncate documentation' do
      expect((Fixed 0.3) / (Fixed 0.1)).to eq (Fixed 3)
    end
  end

  describe 'when comparing numbers' do

    a = Fixed 4
    b = Fixed 7

    it { expect(a < b).to be true }
    it { expect(a > b).to be false }
    it { expect(a == b).to be false }
    it { expect(b == b).to be true }

    it { expect(a.positive?).to be true }
    it { expect(a.negative?).to be false }
    it { expect(a.zero?).to be false }
  end

  describe '#format' do

    it 'represents negative numbers correctly' do

      num = Fixed -3.2

      expect(num.format(18)).to eq "-3.200000000000000000"
      expect(num.format(8)).to eq "-3.20000000"
      expect(num.format(2)).to eq "-3.20"
      expect(num.format(0)).to eq "-3"
    end

    it 'represents positive numbers correctly' do

      num = Fixed 4.8

      expect(num.format(18)).to eq "4.800000000000000000"
      expect(num.format(8)).to eq "4.80000000"
      expect(num.format(2)).to eq "4.80"
      expect(num.format(0)).to eq "5"
    end

    it 'marks not-exactly-zero with an asterisk' do

      num = Fixed.smallest

      expect(num.format(18)).to eq "0.000000000000000001"
      expect(num.format(8)).to eq "0.00000000*"
      expect(num.format(2)).to eq "0.00*"
      expect(num.format(0)).to eq "0*"
    end

    it 'marks negative not-exactly-zero with an asterisk' do

      num = -Fixed.smallest

      expect(num.format(18)).to eq "-0.000000000000000001"
      expect(num.format(8)).to eq "-0.00000000*"
      expect(num.format(2)).to eq "-0.00*"
      expect(num.format(0)).to eq "-0*"
    end
  end

  describe '#inspect' do

    it 'represents positive numbers correctly' do
      expect((Fixed 1e-3).inspect).to eq "0.001000000000000000"
      expect((Fixed 1e-1).inspect).to eq "0.100000000000000000"
      expect((Fixed 1).inspect).to eq "1.000000000000000000"
      expect((Fixed 1e+3).inspect).to eq "1000.000000000000000000"
    end

    it 'represents negative numbers correctly' do
      expect((Fixed -1e-3).inspect).to eq "-0.001000000000000000"
      expect((Fixed -1e-1).inspect).to eq "-0.100000000000000000"
      expect((Fixed -1).inspect).to eq "-1.000000000000000000"
      expect((Fixed -1e3).inspect).to eq "-1000.000000000000000000"
    end

    it 'represents zero correctly' do
      expect((Fixed.zero).inspect).to eq "0.000000000000000000"
    end
  end
end
