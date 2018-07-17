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
    }

    _ = statsdClient.disconnect()
} catch {
    print(error)
}
