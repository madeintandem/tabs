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

Metrics come in two flavors: coutners and values.

### Counter Metrics

A counter metric simply records the number of events that occur within a given timeframe.  To create a counter metric called ‘foobar’, simply call:

    Tabs.create_metric(“foobar”, “counter”)
    
This will set up the metric in the 

To increment a metric counter, simply call:

    Tabs.increment_counter(“foobar”)

To retrieve the counts for a given time period just call:

    Tabs.get_stats(“foobar”, (Time.now - 10.days)..(Time.now), :hour)
    
This will return stats for the last 10 days by hour in a format like this:

    [
      { 2000-01-01 00:00:00 UTC => 1},
      { 2000-01-01 01:00:00 UTC => 0 },
      { 2000-01-01 02:00:00 UTC => 10 },
      { 2000-01-01 03:00:00 UTC => 1 },
      { 2000-01-01 04:00:00 UTC => 0 },
      { 2000-01-01 05:00:00 UTC => 0 },
      { 2000-01-01 06:00:00 UTC => 3 },
      { 2000-01-01 07:00:00 UTC => 0 }
    ]

### Value Metrics

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
