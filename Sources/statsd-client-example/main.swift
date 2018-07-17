import NIO
import StatsdClient

do {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    defer {
        do {
            try group.syncShutdownGracefully()
        } catch {
            print(error)
        }
    }

    let statsdClient = try StatsdClient(host: "127.0.0.1", eventLoopGroup: group)

    for _ in 0..<10 {
        try statsdClient.increment(counter: "foo", by: 2, rate: 0.1)
        try statsdClient.timing(timer: "random_timer", ms: 12)
        try statsdClient.update(gauge: "gas_tank", to: 0.5)
        try statsdClient.update(gauge: "gas_tank", by: -0.2)
    }

    _ = statsdClient.disconnect()
} catch {
    print(error)
}
