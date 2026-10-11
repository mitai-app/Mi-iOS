//
//  ConsoleListItem.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
import UIKit

/// A console presented as a card: platform avatar, name/IP, connection status,
/// and feature chips. Tapping selects it as the active target and expands its
/// inline controls (``ConsoleFeatureView``).
struct ConsoleListItem: View {
    var console: Console

    @State private var expanded: Bool = false
    @State private var isImporting: Bool = false

    @EnvironmentObject var sync: SyncServiceImpl
    @EnvironmentObject var rpi: RPIImpl

    private var isTarget: Bool { sync.target?.ip == console.ip }
    private var isReachable: Bool { console.lastKnownReachable }
    private var canExpand: Bool { console.isPs3 || console.isPs4 }
    private var displayFeatures: [Feature] {
        console.features.filter { $0 != .none && $0 != .netcat }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: select) {
                header
            }
            .buttonStyle(.plain)

            if expanded && canExpand {
                Divider()
                ConsoleFeatureView(item: console)
                    .padding(.top, 4)
            }
        }
        .background(isTarget ? Color("navcolor").opacity(0.06) : Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isTarget ? Color("navcolor") : Color(.separator), lineWidth: isTarget ? 2 : 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(isReachable ? 1 : 0.6)
        .contextMenu { contextMenu }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: InputDoument.readableContentTypes,
            allowsMultipleSelection: true,
            onCompletion: handleImport
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(console.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if console.pinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundColor(Color("navcolor"))
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                if !displayFeatures.isEmpty {
                    chips
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 8) {
                statusPill
                if canExpand {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                }
            }
        }
        .padding(12)
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        console.wifi.isEmpty ? console.ip : "\(console.ip) · \(console.wifi)"
    }

    private var avatar: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(platformColor.opacity(0.14))
            .frame(width: 46, height: 46)
            .overlay(
                VStack(spacing: 1) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 18))
                    Text(platformLabel)
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundColor(platformColor)
            )
    }

    private var chips: some View {
        HStack(spacing: 6) {
            ForEach(Array(displayFeatures.prefix(4)), id: \.self) { feature in
                chip(featureLabel(feature))
            }
            if displayFeatures.count > 4 {
                chip("+\(displayFeatures.count - 4)")
            }
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Status

    private var statusPill: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isTarget && isReachable ? Color.green : Color.clear)
                .overlay(Circle().stroke(isReachable ? Color.gray : Color(.tertiaryLabel), lineWidth: isTarget && isReachable ? 0 : 1.5))
                .frame(width: 7, height: 7)
            Text(statusLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isTarget && isReachable ? Color.green : .secondary)
        }
        .padding(.horizontal, 9).padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isTarget && isReachable ? Color.green.opacity(0.12) : Color.clear)
        )
        .overlay(
            Capsule()
                .stroke(Color(.separator), lineWidth: isTarget && isReachable ? 0 : 0.5)
        )
    }

    private var statusLabel: String {
        if !isReachable { return "Offline" }
        return isTarget ? "Connected" : "Online"
    }

    // MARK: - Platform

    private var platformColor: Color {
        switch console.type {
        case .ps4, .ps5: return .blue
        case .ps3: return .purple
        default: return .gray
        }
    }

    private var platformLabel: String {
        console.type == .unknown ? "?" : console.type.title
    }

    private func featureLabel(_ feature: Feature) -> String {
        switch feature {
        case .rpi: return "RPI"
        case .orbisapi: return "OrbisAPI"
        case .ps3mapi: return "PS3MAPI"
        default: return feature.title
        }
    }

    // MARK: - Context menu

    @ViewBuilder
    private var contextMenu: some View {
        Button {
            sync.target = console
            SyncServiceImpl.shared.findDevice(ip: console.ip) { _ in
                AlertHelper.alert(title: "Success", message: "Console rescanned") { _ in }
            } onError: { error in
                AlertHelper.alert(title: "Error", message: error) { _ in }
            }
        } label: {
            Label("Rescan", systemImage: "arrow.clockwise.circle")
        }

        if console.isPs4 {
            Button {
                sync.target = console
                isImporting.toggle()
            } label: {
                Label("Send payload", systemImage: "shippingbox.circle")
            }
        }
    }

    // MARK: - Actions

    private func select() {
        sync.target = console
        if canExpand {
            withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        Task {
            guard let selectedFile = try? result.get().first else { return }
            if selectedFile.pathExtension == "bin" {
                if selectedFile.startAccessingSecurityScopedResource() {
                    defer { selectedFile.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: selectedFile) {
                        _ = await Goldhen.uploadData(data: data)
                    }
                } else {
                    print("Access denied")
                }
            } else if selectedFile.pathExtension == "pkg" {
                if selectedFile.startAccessingSecurityScopedResource() {
                    defer { selectedFile.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: selectedFile) {
                        let urls = rpi.hostPackage(payloads: PKG(name: selectedFile.lastPathComponent, data: data))
                        rpi.sendDirectRequest(urls: urls) { response in
                            debugPrint(String(data: response, encoding: .utf8) ?? "")
                        } onError: { errorResponse in
                            debugPrint(String(data: errorResponse, encoding: .utf8) ?? "")
                        }
                    }
                } else {
                    print("Access denied")
                }
            } else {
                print("Unsupported file type")
            }
        }
    }
}

struct ConsoleListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            ConsoleListItem(console: fakeConsoles[0])
            ConsoleListItem(console: fakeConsoles[1])
            Spacer()
        }
        .padding()
        .environmentObject(SyncServiceImpl.test())
        .environmentObject(RPIImpl())
    }
}
