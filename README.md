# Tabs

Tabs is a redis-backed metrics tracker that supports counts, sums,
averages, and min/max stats sliceable by the minute, hour, day, week,
month, and year.

## Installation

Add this line to your application's Gemfile:

    gem 'tabs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tabs

## Usage

To count events, simply call the `increment` or `record` methods to
write an event to the store.

### Increment a counter

Tabs.increment(key)

### Record a value

Tabs.record(key, 37)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
