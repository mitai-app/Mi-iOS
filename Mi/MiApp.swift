//
//  MiApp.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

@main
struct MiApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundColor(Color("foreground"))
                .background(Color("background"))
                .environmentObject(SyncServiceImpl.shared)
                .onAppear {
                    SyncServiceImpl.shared.findDevices { consoles in
                        debugPrint(consoles)
                    }
                    Task {
                        ok()
                    }
                }
        }
    }
}
