import NIO
import StatsdClient

do {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    let bootstrap = DatagramBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

    defer {
        do {
            try group.syncShutdownGracefully()
        } catch {
            print(error)
        }
    }

    let channel = try bootstrap.bind(host: "0.0.0.0", port: 0).wait()

    let statsdClient = StatsdClient(host: "127.0.0.1", channel: channel)

    for _ in 0..<10 {
        try statsdClient.send(payload: "foo:1|c")
    }

    _ = channel.close()

    // These lines would connect to the UDP socket vs sending the packets into the ether.
    // The advantage being that if an ICMP packet came back about the port not being opened
    // you'd be warned about it
    //        channel.connect(to: remoteAddress).whenComplete {
    //            var buffer = channel.allocator.buffer(capacity: payload.utf8.count)
    //            buffer.write(string: payload)
    //            channel.writeAndFlush(buffer, promise: nil)
    //        }
    // try channel.closeFuture.wait()
} catch {
    print(error)
}
