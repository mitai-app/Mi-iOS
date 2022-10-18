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
    let rpi: RPI = RPIImpl()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundColor(Color("foreground"))
                .background(Color("background"))
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(SyncServiceImpl.shared)
                .environmentObject(mi as! MiServerImpl)
                .environmentObject(rpi as! RPIImpl)
                .onAppear {
                    SyncServiceImpl.shared.findDevices ({ consoles in
                        debugPrint(consoles)
                    }) { error in
                        AlertHelper.alert(title: "Error", message: error) { action in
                            debugPrint(action)
                        }
                    }
                    mi.start(port: 8080)
                    rpi.start(port: 8081)
                }
        }
    }
}
