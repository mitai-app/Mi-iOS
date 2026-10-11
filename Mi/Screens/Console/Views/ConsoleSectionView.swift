//
//  ConsoleSectionView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
import CoreData
import UIKit

class ConsoleViewModel: ObservableObject {

    let container: NSPersistentContainer = PersistenceController.shared.container
    
    init() {
        
    }
    
    
    func addConsole(string: String) {
        SyncServiceImpl.shared.findDevice(ip: string, onSuccess: { console in
            AlertHelper.alert(title: "Success", message: "Console added!") { action in
                
            }
        }, onError: { error in
            AlertHelper.alertDecision(title: "Warning", message: "Unable to verify that this console is on the network. Would you like to still add this console?") { action in
                debugPrint(action.style)
                switch action.style {
                    
                case .default:
                    print("Adding")
                    let console = Console(
                        ip: string,
                        name: string,
                        wifi: "",
                        lastKnownReachable: true, type: PlatformType.unknown,
                        features: [],
                        pinned: false)
                    _ = console.toConsoleEntity(moc: self.container.viewContext)
                    try? self.container.viewContext.save()
                    break;
                case .cancel:
                    print("Canceled")
                    break;
                case .destructive:
                    print("Destroyed")
                    break;
                @unknown default:
                    print("Unknown Default")
                    break;
                }
                
            }
        })
        
    }
 
}

struct ConsoleSectionView: View {

    @StateObject var vm = ConsoleViewModel()
    @EnvironmentObject var sync: SyncServiceImpl

    @FetchRequest<ConsoleEntity>(
        entity: ConsoleEntity.entity(),
        sortDescriptors: []
    ) var savedEntities: FetchedResults<ConsoleEntity>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if savedEntities.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(savedEntities) { item in
                        ConsoleListItem(console: item.fromConsoleEntity())
                    }
                }
            }
        }
        .padding(16)
        .onAppear {
            if sync.active.isEmpty { sync.findDevices() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text("Consoles")
                    .font(.title2).bold()
                    .foregroundColor(.primary)
                Spacer()
                Button(action: scan) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray6))
                        .foregroundColor(.secondary)
                        .clipShape(Circle())
                }
                Button(action: addConsole) {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color("navcolor"))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add console by IP")
            }
            statusLine
        }
    }

    private var statusLine: some View {
        HStack(spacing: 6) {
            if sync.active.isEmpty {
                ProgressView().scaleEffect(0.7)
                Text("Scanning your network…")
            } else {
                Image(systemName: "wifi")
                Text("\(sync.active.count) found on your network")
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("No consoles yet")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Put your PS4/PS3 on the same Wi-Fi, then scan — or add it by IP.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 10) {
                Button(action: scan) {
                    Label("Scan network", systemImage: "arrow.clockwise")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .overlay(Capsule().stroke(Color("navcolor"), lineWidth: 1))
                        .foregroundColor(Color("navcolor"))
                }
                Button(action: addConsole) {
                    Label("Add by IP", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color("navcolor"))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func scan() {
        sync.findDevices()
    }

    private func addConsole() {
        alertMessage(
            title: "Add console",
            message: "Add a console by IP",
            placeholder: "192.168.1.42",
            onConfirm: { string in vm.addConsole(string: string) }
        ) {
            // cancelled
        }
    }
}

struct ConsoleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleSectionView()
            .environmentObject(SyncServiceImpl.test())
    }
}
