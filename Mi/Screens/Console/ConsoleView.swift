//
//  HomeView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ConsoleView: View {
    
    @StateObject private var vm: ConsoleViewModel = ConsoleViewModel()
    
    @EnvironmentObject var sync: SyncServiceImpl
    
    var body: some View {
        CustomNavView {
            ScrollView {
                ConsoleSectionView()
            }.onAppear {
                
            }.customNavigationTitle("Consoles")
                .customNavigationBarBackButtonHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleView()
            .environmentObject(SyncServiceImpl.test())
        ConsoleView()
            .preferredColorScheme(.dark)
            .environmentObject(SyncServiceImpl.test())
    }
}
