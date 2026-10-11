//
//  KLogView.swift
//  Mi
//

import SwiftUI

/// A live terminal-style view of the PS4 kernel log (GoldHEN, port 3232).
///
/// Streams while on screen and stops when it disappears. Shown in
/// ``ConsoleFeatureView`` for a PS4 that advertises the `.klog` feature.
struct KLogView: View {

    @State var vm: KLogViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            console
            controls
        }
        .padding(.horizontal)
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Kernel Log")
                    .font(.headline).bold()
                    .foregroundColor(Color("navcolor"))
                if let user = vm.latestUser {
                    Text("User: \(user)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Circle()
                .fill(vm.isStreaming ? Color.green : Color.gray)
                .frame(width: 10, height: 10)
            Text(vm.isStreaming ? "Streaming" : "Stopped")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Log console

    private var console: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    if vm.logs.isEmpty {
                        Text(vm.isStreaming ? "Waiting for log output…" : "Not connected.")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(Array(vm.logs.enumerated()), id: \.offset) { index, line in
                            Text(line)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundColor(.green)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(index)
                        }
                    }
                }
                .padding(8)
            }
            .frame(height: 280)
            .background(Color.black)
            .cornerRadius(12)
            .onChange(of: vm.logs.count) { _, newCount in
                guard vm.autoScroll, newCount > 0 else { return }
                withAnimation { proxy.scrollTo(newCount - 1, anchor: .bottom) }
            }
        }
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 16) {
            Button {
                vm.toggle()
            } label: {
                Label(vm.isStreaming ? "Stop" : "Start",
                      systemImage: vm.isStreaming ? "stop.fill" : "play.fill")
            }

            Toggle(isOn: Bindable(vm).autoScroll) {
                Text("Auto-scroll")
            }
            .toggleStyle(.button)
            .font(.caption)

            Spacer()

            Button(role: .destructive) {
                vm.clear()
            } label: {
                Label("Clear", systemImage: "trash")
            }
        }
        .font(.subheadline)
        .tint(Color("navcolor"))
        .padding(.bottom, 8)
    }
}

#if DEBUG
#Preview("Seeded") {
    ScrollView {
        KLogView(vm: KLogViewModel(service: .previewSeeded()))
    }
}

#Preview("Empty") {
    ScrollView {
        KLogView(vm: KLogViewModel(service: KLogService(host: "192.168.1.50")))
    }
}
#endif
