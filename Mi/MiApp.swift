//
//  MiApp.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

@main
struct MiApp: App {
    let persistence = PersistenceController.shared
    let mi: MiServer = MiServerImpl()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundColor(Color("foreground"))
                .background(Color("background"))
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(SyncServiceImpl.shared)
                .environmentObject(mi as! MiServerImpl)
                .onAppear {
                    SyncServiceImpl.shared.findDevices { consoles in
                        debugPrint(consoles)
                    }
                    mi.start()
                }
        }
    }
}
