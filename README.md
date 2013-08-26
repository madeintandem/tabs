![Travis Status](https://api.travis-ci.org/devmynd/tabs.png)

# Tabs

Tabs is a redis-backed metrics tracker that supports counts, sums,
averages, and min/max, and task based stats sliceable by the minute, hour, day, week, month, and year.

## Installation

Add this line to your application's Gemfile:

    gem 'tabs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tabs

## Usage

Metrics come in three flavors: counters, values, and tasks.

### Counter Metrics

A counter metric simply records the number of events that occur within a given timeframe.  To create a counter metric called ‘website-visits’, simply call:

```ruby
Tabs.create_metric("website-visits", "counter")
```

Tabs will also create a counter metric automatically the first time you
increment the counter.

To increment a metric counter, simply call:

```ruby
Tabs.increment_counter("website-visits")
```

If you need to retroactively increment the counter for a specific
timestamp, just pass it in.

```ruby
Tabs.increment_counter("wibsite-visits", Time.now - 2.days)
```

To retrieve the counts for a given time period just call `Tabs#get_stats` with the name of the metric, a range of times defining the period for which you want stats, and the resolution at which the data should be aggregated.

```ruby
Tabs.get_stats("website-visits", 10.days.ago..Time.now, :hour)
```

This will return stats for the last 10 days by hour in the form of a `Tabs::Metrics::Counter::Stats` object.  This object is enumerable so you can iterate through the results like so:

```ruby
results = Tabs.get_stats("website-visits", 10.days.ago..Time.now, :hour)
results.each { |r| puts r }

#=>
  { timestamp: 2000-01-01 00:00:00 UTC, count: 1 }
  { timestamp: 2000-01-01 01:00:00 UTC, count: 0 }
  { timestamp: 2000-01-01 02:00:00 UTC, count: 10 }
  { timestamp: 2000-01-01 03:00:00 UTC, count: 1 }
  { timestamp: 2000-01-01 04:00:00 UTC, count: 0 }
  { timestamp: 2000-01-01 05:00:00 UTC, count: 0 }
  { timestamp: 2000-01-01 06:00:00 UTC, count: 3 }
  { timestamp: 2000-01-01 07:00:00 UTC, count: 0 }
  ...
```

The results object also provides the following methods:

```ruby
results.total       #=> The count total for the given period
results.min         #=> The min count for any timestamp in the period
results.max         #=> The max count for any timestamp in the period
results.avg         #=> The avg count for timestamps in the period
results.period      #=> The timestamp range that was requested
results.resolution  #=> The resolution requested
```

Timestamps for the given period in which no events occurred will be "filled in" with a count value to make visualizations easier.

The timestamps are also normalized.  For example, in hour resolution, the minutes and seconds of the timestamps are set to 00:00.  Likewise for the week resolution, the day is set to the first day of the week.

Lastly, you can access the overall total for a counter (for all time)
using the `counter_total` method.

```ruby
Tabs.counter_total("website-visits") #=> 476873
```

### Value Metrics

Value metrics record a value at a point in time and calculate the min, max, avg, and sum for a given time resolution.  Creating a value metric is easy:

To record a value, simply call `Tabs#record_value`.

```ruby
Tabs.record_value("new-user-age", 32)
```

If you need to retroactively record a value for a specific
timestamp, just pass it in.

```ruby
Tabs.increment_counter("new-user-age", 19, Time.now - 2.days)
```

This will also create a value metric the first time, you can manually create
a metric as well:

```ruby
Tabs.create_metric("new-user-age", "value")
```

Retrieving the stats for a value metric is just like retrieving a counter metric.

```ruby
Tabs.get_stats("new-user-age", 6.months.ago..Time.now, :month)
```

This will return a `Tabs::Metrics::Value::Stats` object.  Again, this
object is enumerable and encapsulates all the timestamps within the
given period.

```ruby
results = Tabs.get_stats("new-user-age", 6.months.ago..Time.now, :month)
results.each { |r| puts r }
#=>
  { timestamp: 2000-01-01 00:00:00, count: 9, min: 19, max: 54, sum: 226, avg: 38 }
  { timestamp: 2000-02-01 01:00:00, count: 0, min: 0, max: 0, sum: 0, avg: 0 }
  { timestamp: 2000-03-01 02:00:00, count: 2, min: 22, max: 34, sum: 180, avg: 26 }
  ...
```

The results object also provides some aggregates and other methods:

```ruby
results.count       #=> The total count of recorded values for the period
results.sum         #=> The sum of all values for the period
results.min         #=> The min value for any timestamp in the period
results.max         #=> The max value for any timestamp in the period
results.avg         #=> The avg value for timestamps in the period
results.period      #=> The timestamp range that was requested
results.resolution  #=> The resolution requested
```

### Task Metrics

Task metrics allow you to track the beginning and ending of a process.
For example, tracking a user who downloads you mobile application and
later visits your website to make a purchase.

```ruby
Tabs.start_task("mobile-to-purchase", "2g4hj17787s")
```

The first argument is the metric key and the second is a unique token
used to identify the given process.  You can use any string for the
token but it needs to be unique.  Use the `complete_task` method to
finish the task:

```ruby
Tabs.complete_task("mobile-to-purchase", "2g4hj17787s")
```

If you need to retroactively start/complete a task at a specific
timestamp, just pass it in.

```ruby
Tabs.start_task("mobile-to-purchase", "2g4hj17787s", Time.now - 2.days)
Tabs.complete_task("mobile-to-purchase", "2g4hj17787s", Time.now - 1.days)
```

Retrieving stats for a task metric is just like the other types:

```ruby
Tabs.get_stats("mobile-to-purchase", 6.hours.ago..Time.now, :minute)
```

This will return a `Tabs::Metrics::Task::Stats` object:

```ruby
results = Tabs.get_stats("mobile-to-purchase", 6.hours.ago..Time.now, :minute)
results.started_within_period       #=> Number of items started in period
results.completed_within_period     #=> Number of items completed in period
results.started_and_completed_within_period  #=> Items wholly started/completed in period
results.completion_rate             #=> Rate of completion in the given resolution
results.average_completion_time     #=> Average time for the task to be completed
```

### Resolutions

When tabs increments a counter or records a value it does so for each of the following "resolutions".  You may supply any of these as the last argument to the `Tabs#get_stats` method.

    :minute, :hour, :day, :week, :month, :year

It automatically aggregates multiple events for the same period.  For instance when you increment a counter metric, 1 will be added for each of the resolutions for the current time.  Repeating the event 5 minutes later will increment a different minute slot, but the same hour, date, week, etc.  When you retrieve metrics, all timestamps will be in UTC.

#### Custom Resolutions

If the built-in resolutions above don't work you can add your own.  All
that's necessary is a module that conforms to the following protocol:

```ruby
module SecondResolution
  extend Tabs::Resolutionable
  extend self

  PATTERN = "%Y-%m-%d-%H-%M-%S"

  def serialize(timestamp)
    timestamp.strftime(PATTERN)
  end

  def deserialize(str)
    dt = DateTime.strptime(str, PATTERN)
    self.normalize(dt)
  end

  def from_seconds(s)
    s / 1
  end

  def normalize(ts)
    Time.utc(ts.year, ts.month, ts.day, ts.hour, ts.min, ts.sec)
  end
end

```

A little description on each of the above methods:

*`serialize`*: converts the timestamp to a string.  The return value
here will be used as part of the Redis key storing values associated
with a given metric.

*`deserialize`*: converts the string representation of a timestamp back
into an actual DateTime value.

*`from_seconds`*: should return the number of periods in the given
number of seconds.  For example, there are 60 seconds in a minute.

*`normalize`*: should simply return the first timestamp for the period.
For example, the week resolution returns the first hour of the first day
of the week.

*NOTE: If you're doing a custom resolution you should probably look into
the code a bit.*

Once you have a module that conforms to the resolution protocol you need
to register it with Tabs.  You can do this in one of two ways:

```ruby
# This call can be anywhere before you start using tabs
Tabs::Resolution.register(:second, SecondResolution)

# or, you can use the config block described below
```

### Inspecting Metrics

You can list all metrics using `list_metrics`:

```ruby
Tabs.list_metrics #=> ["website-visits", "new-user-age"]
```

You can check a metric's type (counter of value) by calling
`metric_type`:

```ruby
Tabs.metric_type("website-visits") #=> "counter"
```

And you can quickly check if a metric exists:

```ruby
Tabs.metric_exists?("foobar") #=> false
```

### Drop a Metric

To drop a metric, just call `Tabs#drop_metric`

```ruby
Tabs.drop_metric!("website-visits")
```

This will drop all recorded values for the metric so it may not be un-done...be careful.

Even more dangerous, you can drop all metrics...be very careful.

```ruby
Tabs.drop_all_metrics!
```

### Configuration

Tabs just works out of the box. However, if you want to override the default Redis connection or decimal precision, this is how:

```ruby
Tabs.configure do |config|

  # set it to an existing connection
  config.redis = Redis.current

  # pass a config hash that will be passed to Redis.new
  config.redis = { :host => 'localhost', :port => 6379 }

  # override default decimal precision (5)
  # affects stat averages and task completion rate
  config.decimal_precision = 2

  # registers a custom resolution
  config.register_resolution :second, SecondResolution

end
```

## Breaking Changes

### v0.6.0

Please note that when the library version went from v0.5.6 to v0.6.0 some of
the key patterns used to store metrics in Redis were changed.  If you upgrade
an app to v0.6.0 the previous set of data will not be picked up by tabs.
Please use v0.6.x on new applications only.  However, the 'Task' metric
type will only be available in v0.6.0 and above.

### v0.8.0

In version 0.8.0 and higher the get_stats method returns a more robust
object instead of just an array of hashes.  These stats objects are
enumerable and most existing code utilizing tabs should continue to
function.  However, please review the docs for more information if you
encounter issues when upgrading.

### v0.8.2

In version 0.8.2 and higher the storage keys for value metrics have been
changed.  Originally the various pieces (avg, sum, count, etc) were
stored in a JSON serialized string in a single key.  The intent was that
this would comprise a poor-mans transaction of sorts.  The downside
however was a major hit on performance when doing a lot of writes or
reading stats for a large date range.  In v0.8.2 these component values
are stored in a real Redis hash and updated atomically when a value is
recorded.  In future versions this will be changed to use a MULTI
statement to simulate a transaction.  Value data that was recorded prior
to v0.8.2 will not be accessible in this or future versions so please
continue to use v0.8.1 or lower if that is an issue.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
