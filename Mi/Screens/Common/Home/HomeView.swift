//
//  HomeView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var changelogs: Changelog? = nil
    
    
    func getChangelogs() {
        Package.getMeta { response in
            self.changelogs = response
        }
    }
}

struct HomeView: View {
    
    @StateObject private var vm: HomeViewModel = HomeViewModel()
    
    @StateObject var sync: SyncService
    
    var body: some View {
        CustomNavView {
            ScrollView {
                
                ConsoleSectionView(sync: sync)
                
                if let change = vm.changelogs {
                    ChangelogSectionView(change: change)
                }
                
                
            }.background(Color("quinary")).onAppear {
                vm.getChangelogs()
            }.customNavigationTitle("Home")
                .customNavigationBarBackButtonHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(sync: SyncService.test())
            .foregroundColor(.white)
    }
}
