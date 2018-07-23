import NIO

public let defaultStatsdPort = 8125

fileprivate let onDemandSharedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public class StatsdClient {
    public let host: String
    public let port: Int
    public let channel: Channel
    
    public init(host: String = "127.0.0.1", port: Int = defaultStatsdPort, channel: Channel) {
        self.host = host
        self.port = port
        self.channel = channel
    }

    public convenience init(host: String = "127.0.0.1", port: Int = defaultStatsdPort, eventLoopGroup: EventLoopGroup? = nil) throws {
        let group = eventLoopGroup
            ?? MultiThreadedEventLoopGroup.currentEventLoop
            ?? onDemandSharedEventLoopGroup

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
    
    // MARK: Counters
    
    public func counterMetric(bucket: String, amount: Int = 1, rate: Double? = nil) -> String {
        if let rate = rate {
            return "\(bucket):\(amount)|c|@\(rate)"
        } else {
            return "\(bucket):\(amount)|c"
        }
    }
    
    public func increment(counter bucket: String, by amount: Int = 1, rate: Double? = nil) throws {
        try send(payload: counterMetric(bucket: bucket, amount: amount, rate: rate))
    }

    public func decrement(counter bucket: String, by amount: Int = 1, rate: Double? = nil) throws {
        try increment(counter: bucket, by: amount, rate: rate)
    }

    // MARK: Timers
    
    public func timerMetric(bucket: String, durationInMs: Int, rate: Double? = nil) -> String {
        if let rate = rate {
            return "\(bucket):\(durationInMs)|ms|@\(rate)"
        } else {
            return "\(bucket):\(durationInMs)|ms"
        }
    }
    
    public func timing(timer bucket: String, ms durationInMs: Int, rate: Double? = nil) throws {
        try send(payload: timerMetric(bucket: bucket, durationInMs: durationInMs, rate: rate))
    }

    // MARK: Gauges
    
    public func gaugeMetric(bucket: String, value: Int) -> String {
        return "\(bucket):\(value)|g"
    }
    
    public func gaugeMetric(bucket: String, value: Double) -> String {
        return "\(bucket):\(value)|g"
    }

    public func update(gauge bucket: String, to value: Int) throws {
        try send(payload: gaugeMetric(bucket: bucket, value: value))
    }
    
    public func update(gauge bucket: String, by delta: Int) throws {
        try send(payload: gaugeMetric(bucket: bucket, value: delta))
    }

    public func update(gauge bucket: String, to value: Double) throws {
        try send(payload: gaugeMetric(bucket: bucket, value: value))
    }
    
    public func update(gauge bucket: String, by delta: Double) throws {
        try send(payload: gaugeMetric(bucket: bucket, value: delta))
    }
    
    // MARK: Sets
    
    public func setMetric(bucket: String, value: CustomStringConvertible) -> String {
        return "\(bucket):\(value)|s"
    }

    public func insert(set bucket: String, value: CustomStringConvertible) throws {
        try send(payload: setMetric(bucket: bucket, value: value))
    }
}
