//
//  KLogService.swift
//  Mi
//

import Foundation
import Socket

/// Streams GoldHEN's kernel log from a PS4 over a dedicated socket.
///
/// Unlike the request/response protocols, the KLog socket is long-lived, so it
/// is owned here rather than borrowed from `SyncServiceImpl`'s shared socket
/// cache — a blocking read loop must not tie up a socket other callers reuse.
/// The read loop runs off the main actor (a detached task); completed lines are
/// published back on the main actor so SwiftUI observation stays correct.
///
/// This is the reference pattern for the iOS modernization: `@Observable` state,
/// `async`/`await`, no `SyncServiceImpl.shared` reach-in, no `print`.
@MainActor
@Observable
final class KLogService: KLog {

    private(set) var logs: [String] = []
    private(set) var isStreaming = false

    /// Last PSN user seen logging in, parsed from the stream (nice-to-have that
    /// mirrors Android's username extraction). `nil` until one is observed.
    private(set) var latestUser: String?

    private let host: String
    private let port: Int

    private var task: Task<Void, Never>?
    /// Touched from the read loop and from `disconnect()`; closing it from
    /// another thread is the intended way to unblock a blocked `readString()`.
    nonisolated(unsafe) private var activeSocket: Socket?

    init(host: String, port: Int = 3232) {
        self.host = host
        self.port = port
    }

    convenience init(console: Console) {
        self.init(host: console.ip, port: Feature.klog.ports.first ?? 3232)
    }

    func connect() {
        guard task == nil else { return }          // already streaming
        isStreaming = true
        let host = self.host
        let port = self.port
        task = Task.detached(priority: .utility) { [weak self] in
            await self?.stream(host: host, port: port)
        }
    }

    func disconnect() {
        task?.cancel()
        task = nil
        // readLine()/readString() ignore cancellation; closing unblocks them.
        activeSocket?.close()
        activeSocket = nil
        isStreaming = false
    }

    func clear() {
        logs.removeAll()
        latestUser = nil
    }

    // MARK: - Streaming (off the main actor)

    nonisolated private func stream(host: String, port: Int) async {
        let socket: Socket
        do {
            socket = try Socket.create()
            try socket.connect(to: host, port: Int32(port), timeout: UInt(SyncServiceImpl.timeout))
        } catch {
            await finishStreaming()
            return
        }
        await setActiveSocket(socket)
        defer { socket.close() }

        var accumulator = LineAccumulator()
        do {
            while !Task.isCancelled {
                // nil / empty means the console closed the stream.
                guard let chunk = try socket.readString(), !chunk.isEmpty else { break }
                let lines = accumulator.append(chunk)
                if !lines.isEmpty { await ingest(lines) }
            }
        } catch {
            // Stream ended (remote close, or the socket was closed to unblock us).
        }
        if let tail = accumulator.flush() { await ingest([tail]) }
        await finishStreaming()
    }

    // MARK: - Main-actor state updates

    private func setActiveSocket(_ socket: Socket) {
        activeSocket = socket
    }

    private func ingest(_ newLines: [String]) {
        logs.append(contentsOf: newLines)
        let overflow = logs.count - Self.maxBufferedLines
        if overflow > 0 { logs.removeFirst(overflow) }

        for line in newLines where line.contains("logged in") {
            if let user = KLogParsing.quotedValue(in: line) { latestUser = user }
        }
    }

    private func finishStreaming() {
        isStreaming = false
        task = nil
        activeSocket = nil
    }
}

#if DEBUG
extension KLogService {

    /// A service pre-seeded with sample lines for previews (no socket needed).
    static func previewSeeded() -> KLogService {
        let service = KLogService(host: "192.168.1.50")
        service.logs = [
            "<118>[SceUserService] User \"Mr-Smithy-x\" (0x10000000) logged in",
            "<119>[Kernel] mounting /data",
            "<118>[GoldHEN] plugin loaded: no_share_err.prx",
            "<120>[SceShellCore] app launch: CUSA12345"
        ]
        service.latestUser = "Mr-Smithy-x"
        return service
    }
}
#endif
