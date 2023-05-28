# Fixed

Fixed is a Ruby gem that provides a fixed-point implementation of numbers with 18-digit precision. It is designed to avoid issues with floating-point rounding errors and ensures that arithmetic operations are performed with full precision. This gem is useful in situations where it is necessary to represent rational numbers with a high degree of precision, such as in scientific or financial applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixed'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fixed

## Usage

Here's an example of how to use the Fixed gem:

```ruby
require 'fixed'

# Create Fixed instances
a = Fixed(1)
b = Fixed(6)

# Perform arithmetic operations
sum = a + b
difference = a - b
product = a * b
ratio = a / b

# Output the results
puts "Sum: #{sum}"                  # => Sum: 7.00000000
puts "Difference: #{difference}"    # => Difference: -5.00000000
puts "Product: #{product}"          # => Product: 6.00000000
puts "Ratio: #{ratio.format(18)}"   # => Ratio: 0.166666666666666667
```

In the above example, the Fixed gem allows you to perform arithmetic operations with high precision, avoiding rounding errors that can occur with floating-point numbers.

## API

### Fixed Class

The `Fixed` class represents a fixed-point number with 18-digit precision.

#### Constructors

- `Fixed.parse(str)`: Creates a new `Fixed` instance by parsing a string representation of a fixed-point number.
- `Fixed.from_number(number)`: Creates a new `Fixed` instance from a numeric value.
- `Fixed.from_fractions(fractions)`: Creates a new `Fixed` instance from the raw number of fractions.
- `Fixed.smallest`: Returns a `Fixed` instance representing the smallest possible value (1e-18).
- `Fixed.zero`: Returns a `Fixed` instance representing zero (0).

#### Arithmetic Operations

The `Fixed` class supports the following arithmetic operations:

- `+`, `-`, `*`, `/`: Addition, subtraction, multiplication, and division operations.
- `-@`: Unary negation (returns a new `Fixed` instance with the opposite sign).
- `abs`: Returns the absolute value of the `Fixed` instance.

#### Comparisons

The `Fixed` class includes the `Comparable` module, allowing you to compare instances of `Fixed` using comparison operators such as `<`, `>`, `<=`, `>=`, `==`, and `<=>`.

#### String Formatting

- `to_s(precision = 8)`: Returns a string representation of the `Fixed` instance with the specified precision.
- `format(precision = 8)`: Returns a formatted string representation of the `Fixed` instance with the specified precision.
- `pretty_format(precision = 8)`: Returns a formatted string representation of the `Fixed` instance with the specified precision, including thousands separators.

### Kernel Method

The `Fixed` gem also adds a `Fixed` method to the `Kernel` module, allowing you to create `Fixed` instances using a convenient syntax. For example:

```ruby
a = Fixed(1)
```

This is equivalent to:

```ruby
a = Fixed.from_number(1)
```

### Numeric Extension

The `Fixed` gem extends the `Numeric` class with a `to_fixed` method, allowing you to convert numeric values to `Fixed` instances. For example:

```ruby
number = 1.23
fixed = number.to_fixed
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/akuhn/fixed](https://github.com/akuhn/fixed). This project encourages collaboration and appreciates contributions. Feel free to contribute to the project by reporting bugs or submitting pull requests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
