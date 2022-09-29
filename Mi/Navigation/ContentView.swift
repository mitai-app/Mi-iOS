//
//  ContentView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @StateObject var sync: SyncService = SyncService.shared
    
    var body: some View {
        TabView {
            HomeView(sync: sync).tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            ListView().tabItem {
                Image(systemName: "paperplane.fill")
                Text("Payload")
            }
            SettingView().tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

class ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sync: SyncService.test()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
#if DEBUG
    @objc class func injected() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: ContentView())
    }
#endif
}
