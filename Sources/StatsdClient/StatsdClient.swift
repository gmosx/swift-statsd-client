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

//    public convenience init(host: String = "127.0.0.1", port: Int = defaultStatsdPort) {
//    }

    public func send(payload: String) throws {
        let remoteAddress = try SocketAddress.newAddressResolving(host: host, port: port)
        
        var buffer = channel.allocator.buffer(capacity: payload.utf8.count)
        buffer.write(string: payload)
        
        let envelope = AddressedEnvelope(remoteAddress: remoteAddress, data: buffer)
        channel.writeAndFlush(envelope, promise: nil)
    }
}

