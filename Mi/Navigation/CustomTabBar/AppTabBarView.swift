//
//  AppTabBarView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

// Generics
// ViewBuilder
// PreferenceKey
// MatchGeometryEffect

struct AppTabBarView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selection: String = "home"
    @State var tabSelection: TabBarItem = .home
    
    @StateObject var sync: SyncService = SyncService.shared
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection, background: Color.white) {
            
            HomeView(sync: sync).tabBarItem(tab: .home, selection: $tabSelection)
                ListView().tabBarItem(tab: .favorites, selection: $tabSelection)
                SettingView().tabBarItem(tab: .profile, selection: $tabSelection)
            
        }
    }
}

class AppTabBarView_Previews: PreviewProvider {
    
#if DEBUG
    @objc class func injected() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController =
                UIHostingController(rootView: ContentView())
    }
#endif
    static var previews: some View {
        AppTabBarView(tabSelection: .home).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


extension AppTabBarView {
    private var defaultTabView: some View {
        TabView(selection: $selection) {
            
            Color.red.tabItem {
                Image(systemName: "house")
                Text("Tab Content 1")
            }
            
            Color.red.tabItem {
                Image(systemName: "heart")
                Text("Favorites")
            }
            
            Color.red.tabItem {
                Image(systemName: "person")
                Text("Person")
            }
            
            
        }
    }
}
