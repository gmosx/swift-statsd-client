import NIO

// TODO: support both UDP and TCP
// TODO: automatically switch between UDP and TCP
// TODO: add support for logging

public let defaultStatsdPort = 8125

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public class StatsdClient {
    public let host: String
    public let port: Int
    public let channel: Channel
    
    public init(host: String = "127.0.0.1", port: Int = defaultStatsdPort, channel: Channel) {
        self.host = host
        self.port = port
        self.channel = channel
    }

    public convenience init(host: String = "127.0.0.1", port: Int = defaultStatsdPort, eventLoopGroup: EventLoopGroup) throws {
        let bootstrap = DatagramBootstrap(group: group)
            .channelOption(
                ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR),
                value: 1
            )
        
        // https://github.com/apple/swift-nio/issues/215#issuecomment-405199510
        let channel = try bootstrap.bind(host: "0.0.0.0", port: 0).wait()
        
        self.init(host: host, port: port, channel: channel)
    }

    public func disconnect() -> EventLoopFuture<Void> {
        return channel.close()
    }
    
    public func send(payload: String) throws {
        let remoteAddress = try SocketAddress.newAddressResolving(host: host, port: port)
        
        var buffer = channel.allocator.buffer(capacity: payload.utf8.count)
        buffer.write(string: payload)
        
        let envelope = AddressedEnvelope(remoteAddress: remoteAddress, data: buffer)
        channel.writeAndFlush(envelope, promise: nil)
    }
    
    public func increment(counter counterName: String, by amount: Int = 1) throws {
        try send(payload: "\(counterName):\(amount)|c")
    }

    public func decrement(counter counterName: String, by amount: Int = 1) throws {
        try send(payload: "\(counterName):\(-amount)|c")
    }
}

// These lines would connect to the UDP socket vs sending the packets into the ether.
// The advantage being that if an ICMP packet came back about the port not being opened
// you'd be warned about it
//        channel.connect(to: remoteAddress).whenComplete {
//            var buffer = channel.allocator.buffer(capacity: payload.utf8.count)
//            buffer.write(string: payload)
//            channel.writeAndFlush(buffer, promise: nil)
//        }
// try channel.closeFuture.wait()
