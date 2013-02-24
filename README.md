![Travis Status](https://api.travis-ci.org/thegrubbsian/tabs.png)

# Tabs

Tabs is a redis-backed metrics tracker that supports counts, sums, averages, and min/max stats sliceable by the minute, hour, day, week, month, and year.

## Installation

Add this line to your application's Gemfile:

    gem 'tabs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tabs

## Usage

Metrics come in two flavors: counters and values.

### Counter Metrics

A counter metric simply records the number of events that occur within a given timeframe.  To create a counter metric called ‘website-visits’, simply call:

    Tabs.create_metric(“website-visits”, “counter”)

Tabs will also create a counter metric automatically the first time you
increment the counter.

To increment a metric counter, simply call:

    Tabs.increment_counter(“website-visits”)

To retrieve the counts for a given time period just call `Tabs#get_stats` with the name of the metric, a range of times defining the period for which you want stats, and the resolution at which the data should be aggregated.

    Tabs.get_stats(“website-visits”, (Time.now - 10.days)..Time.now, :hour)
    
This will return stats for the last 10 days by hour as an array of hashes in which the keys are an instance of `Time` and the value is the count for that time.

    [
      { 2000-01-01 00:00:00 UTC => 1 },
      { 2000-01-01 01:00:00 UTC => 0 },
      { 2000-01-01 02:00:00 UTC => 10 },
      { 2000-01-01 03:00:00 UTC => 1 },
      { 2000-01-01 04:00:00 UTC => 0 },
      { 2000-01-01 05:00:00 UTC => 0 },
      { 2000-01-01 06:00:00 UTC => 3 },
      { 2000-01-01 07:00:00 UTC => 0 },
      ...
    ]
    
Times for the given period in which no events occurred will be “filled in” with a zero value to make visualizations easier.

The `Time` keys are also normalized.  For example, in hour resolution, the minutes and seconds of the `Time` object are set to 00:00.  Likewise for the week resolution, the day is set to the first day of the week.

### Value Metrics

Value metrics take a value and record the min, max, avg, and sum for a given time resolution.  Creating a value metric is easy:

To record a value, simply call `Tabs#record_value`.

    Tabs.record_value(“new-user-age”, 32)

This will also create a value metric the first time, you can manually create
a metric as well:

    Tabs.create_metric("new-user-age", "value")
    
Retrieving the stats for a value metric is just like retrieving a counter metric.

    Tabs.get_stats(“new-user-age”, (Time.now - 6.months)..Time.now, :month)
    
This will return a familiar value, but with an expanded set of values.

    [
      { 2000-01-01 00:00:00 UTC => { min: 19, max: 54, sum: 226, avg: 38 } },
      { 2000-02-01 01:00:00 UTC => { min: 0, max: 0, sum: 0, avg: 0 } },
      { 2000-03-01 02:00:00 UTC => { min: 22, max: 34, sum: 180, avg: 26 } },
      ...
    ]

### Resolutions

When tabs increments a counter or records a value it does so for each of the following “resolutions”.  You may supply any of these as the last argument to the `Tabs#get_stats` method.

    :minute, :hour, :day, :week, :month, :year

It automatically aggregates multiple events for the same period.  For instance when you increment a counter metric, 1 will be added for each of the resolutions for the current time.  Repeating the event 5 minutes later will increment a different minute slot, but the same hour, date, week, etc.  When you retrieve metrics, all timestamps will be in UTC.

### Inspecting Metrics

You can list all metrics using `list_metrics`:

    Tabs.list_metrics #=> ["website-visits", "new-user-age"]

You can check a metric's type (counter of value) by calling
`metric_type`:

    Tabs.metric_type("website-visits") #=> "counter"

And you can quickly check if a metric exists:

    Tabs.metric_exists?("foobar") #=> false

### Drop a Metric

To drop a metric, just call `Tabs#drop_metric`

    Tabs.drop_metric(“website-visits”)
    
This will drop all recorded values for the metric so it may not be un-done...be careful.

### Configuration

There really isn’t much to configure with Tabs, it just works out of the box.  You can use the following configure block to set the Redis connection instance that Tabs will use.

    Tabs.configure do |config|
    
      # set it to an existing connection
      config.redis = Redis.current
      
      # pass a config hash that will be passed to Redis.new
      config.redis = { :host => 'localhost', :port => 6379 }
      
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
