//
//  RepoPackageListView.swift
//  Mi
//
//  Created by Vonley on 10/6/22.
//

import SwiftUI

class RepoPackageListViewModel: ObservableObject {
    init() {}

    func startDownload(_ console: Console, _ model: PackageModel, _ version: String, _ link: String) {
        print("Downloading \(model.name): \(model.version) - \(version)")
        SyncServiceImpl.psx.getRequest(url: link) { res in
            do {
                if let data = try res.result.get() {
                    print("Downloaded \(model.name): \(model.version) - \(version)")
                    Task(priority: .background) {
                        print("Connecting to goldenhen via \(console.ip) and sending payload")
                        if await Goldhen.uploadData(data: data) {
                            await MainActor.run {
                                print("Uploaded to goldenhen \(model.name): \(model.version) - \(version)")
                            }
                        }
                    }
                }
            } catch {
                print("Error downloading \(model.name): \(model.version) - \(version)")
                debugPrint(error)
            }
        }
    }
}

/// Rows of packages with a visible install control. The install flow is explicit:
/// with no PS4 target the button reads "Select console" and offers a picker;
/// with a target it offers the available versions (or installs directly when a
/// package ships a single build).
struct PackageListView: View {
    let packages: [PackageModel]

    @EnvironmentObject var sync: SyncServiceImpl
    @StateObject private var vm = RepoPackageListViewModel()

    @State private var selected: PackageModel?
    @State private var showPicker = false

    private var hasPs4Target: Bool { sync.target?.isPs4 == true }
    private var ps4Consoles: [Console] { sync.getPotentialClients().filter { $0.isPs4 } }

    private var pickerTitle: String {
        if !hasPs4Target { return "Select a console" }
        return selected.map { "\($0.name) versions" } ?? "Versions"
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(packages.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Divider().padding(.leading, 72)
                }
                HStack(spacing: 12) {
                    PackageViewItem(package: item)
                    installButton(for: item)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
            }
        }
        .confirmationDialog(
            pickerTitle,
            isPresented: $showPicker,
            titleVisibility: .visible
        ) {
            if !hasPs4Target {
                ForEach(ps4Consoles) { console in
                    Button("\(console.type.title): \(console.ip)") { sync.target = console }
                }
                Button("Scan network") { sync.findDevices() }
            } else if let item = selected {
                ForEach(versionKeys(for: item), id: \.self) { key in
                    Button(key) { install(item, version: key, link: item.dl[key] ?? item.link) }
                }
            }
        } message: {
            if !hasPs4Target {
                Text(ps4Consoles.isEmpty ? "No PS4 found yet. Scan your network to find one." : "Choose a PS4 to install to.")
            } else {
                Text("Download a version to your PS4.")
            }
        }
    }

    private func installButton(for item: PackageModel) -> some View {
        Button {
            selected = item
            if hasPs4Target && item.dl.isEmpty {
                install(item, version: item.version, link: item.link)
            } else {
                showPicker = true
            }
        } label: {
            if hasPs4Target {
                Label("Get", systemImage: "arrow.down.to.line")
                    .labelStyle(.titleAndIcon)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Color("navcolor"))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            } else {
                Text("Select console")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .overlay(Capsule().stroke(Color("navcolor"), lineWidth: 1))
                    .foregroundColor(Color("navcolor"))
            }
        }
        .buttonStyle(.plain)
    }

    private func versionKeys(for item: PackageModel) -> [String] {
        item.dl.isEmpty ? [item.version] : item.dl.keys.sorted(by: >)
    }

    private func install(_ item: PackageModel, version: String, link: String) {
        guard let target = sync.target else { return }
        vm.startDownload(target, item, version, link)
    }
}

struct RepoPackageListView_Previews: PreviewProvider {
    static var previews: some View {
        let response = PackageResponse(title: "Title", author: "Author", banner: "Banner", description: "Description", packages: [PackageModel(
        name: "GoldHen",
        author: "SiStRo",
        version: "2.2.4",
        type: PackageType.plugin,
        icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
        link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
        dl: [:])])
        PackageListView(packages: response.packages)
            .environmentObject(SyncServiceImpl.test())
    }
}
