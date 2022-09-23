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
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
