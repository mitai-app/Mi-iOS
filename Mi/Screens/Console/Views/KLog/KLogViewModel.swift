//
//  KLogViewModel.swift
//  Mi
//

import Foundation

/// View model for ``KLogView``. Thin on purpose: it owns a ``KLogService`` and
/// exposes just the state the view renders plus the intents it triggers, so the
/// view stays declarative. Part of the modernized MVVM pattern (`@Observable`,
/// held by the view with `@State`).
@MainActor
@Observable
final class KLogViewModel {

    private let service: KLogService

    /// Whether the console should auto-scroll to the newest line.
    var autoScroll = true

    var logs: [String] { service.logs }
    var isStreaming: Bool { service.isStreaming }
    var latestUser: String? { service.latestUser }

    init(console: Console) {
        self.service = KLogService(console: console)
    }

    /// For previews/tests with a custom (e.g. pre-seeded) service.
    init(service: KLogService) {
        self.service = service
    }

    func start() { service.connect() }
    func stop() { service.disconnect() }
    func toggle() { service.isStreaming ? service.disconnect() : service.connect() }
    func clear() { service.clear() }
}
