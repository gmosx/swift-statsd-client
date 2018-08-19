# StatsdClient

A client for [StatsD](https://github.com/etsy/statsd) servers.

## Example

```
let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

let statsdClient = try StatsdClient(host: "127.0.0.1", eventLoopGroup: group)

statsdClient.increment(counter: "foo", by: 2, rate: 0.1)
statsdClient.timing(timer: "random_timer", ms: 12)
statsdClient.update(gauge: "gas_tank", to: 0.5)
statsdClient.update(gauge: "gas_tank", by: -0.2)
statsdClient.insert(set: "unique_users", value: "3213FA")
statsdClient.insert(set: "unique_users", value: "3213FA")
statsdClient.insert(set: "unique_users", value: "3213F1")
```

## Evaluation

Download and setup the reference [StatsD server](https://github.com/etsy/statsd). For evaluation you can dump metrics the `console` backend by using the following config:

```
{
    port: 8125,
    backends: [ "./backends/console" ]
}
```

Start the `StatsD` daemon:

```
node stats.js config.js 
```

Run the included `statsd-client-example`:

```
swift run statsd-client-example
```

## License

The software and all related files are licensed under the MIT license.

(c) 2018 Reizu.
