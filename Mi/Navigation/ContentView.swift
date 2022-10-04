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

    
    var body: some View {
        TabView {
            FTPView().tabItem {
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

class ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}
