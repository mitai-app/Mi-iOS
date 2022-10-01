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
    
    @State private var selection: String = "home"
    @State var tabSelection: TabBarItem = .home
    @State var color: Color = Color("quinary")
    @StateObject var sync: SyncService = SyncService.shared
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection, background: color) {
            
            HomeView(sync: sync).tabBarItem(tab: .home, selection: $tabSelection).foregroundColor(.white)
            PackageView(sync: sync, background: color)
                .tabBarItem(tab: .package, selection: $tabSelection)
            SettingView(sync: sync)
                .tabBarItem(tab: .settings, selection: $tabSelection)
            
        }
    }
}

class AppTabBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        AppTabBarView(tabSelection: .home, color: Color("quinary"), sync: SyncService.test())
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
