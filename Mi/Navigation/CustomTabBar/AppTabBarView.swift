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
    
    @State var tabSelection: TabBarItem = .home
    @State var color: Color
    @EnvironmentObject var sync: SyncServiceImpl
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection, background: color) {
            IntroView().tabBarItem(tab: .home, selection: $tabSelection)
            ConsoleView().tabBarItem(tab: .consoles, selection: $tabSelection)
            PackageView().tabBarItem(tab: .package, selection: $tabSelection)
            FTPView().tabBarItem(tab: .ftp, selection: $tabSelection)
            SettingView().tabBarItem(tab: .settings, selection: $tabSelection)
            
        }
    }
}

class AppTabBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        AppTabBarView(tabSelection: .home, color: Color("tabcolor"))
            .environmentObject(SyncServiceImpl.test())
        
            AppTabBarView(tabSelection: .home, color: Color("tabcolor"))
                .environmentObject(SyncServiceImpl.test())
                .preferredColorScheme(.dark)
    }
}
