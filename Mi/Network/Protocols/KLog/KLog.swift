//
//  KLog.swift
//  Mi
//
//  GoldHEN's kernel-log stream (PS4, socket port 3232).
//

import Foundation

/// Live view onto GoldHEN's kernel log, streamed over a socket (port 3232).
///
/// Mirrors the Android `KLog` contract (`di/network/protocols/klog/KLog.kt`):
/// a running buffer of recent log lines plus a streaming flag, with explicit
/// `connect()` / `disconnect()`. Conformers are observable so SwiftUI can bind
/// directly to `logs` and `isStreaming`.
@MainActor
protocol KLog: AnyObject {

    /// Recent raw log lines, oldest first. Capped at ``maxBufferedLines``.
    var logs: [String] { get }

    /// Whether the background read loop is currently streaming.
    var isStreaming: Bool { get }

    /// Opens the socket (if needed) and begins streaming lines.
    func connect()

    /// Cancels streaming and closes the socket.
    func disconnect()

    /// Drops all buffered lines.
    func clear()
}

extension KLog {

    /// Max lines retained in memory. Matches Android's `REPLAY` buffer so the
    /// two apps show a comparable amount of scrollback.
    static var maxBufferedLines: Int { 500 }
}
