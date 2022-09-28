//
//  HomeView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var changelogs: [Changelog] = []
    
    func getChangelogs() {
        self.changelogs = fakeChangeLogs
    }
        
}

struct HomeView: View {
    
    @StateObject private var vm: HomeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                ConsoleSectionView(sync: SyncService.shared)
                
                Text("Change Logs")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(vm.changelogs) { item in
                            NavigationLink(destination: ChangelogFeatureView(item: item)) {
                                ChangelogCardView(item: item)
                            }
                        }
                    }
                    .padding()
                }
                
                
                Text("Recent courses")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(fakeConsoles) { item in
                        NavigationLink(destination: ConsoleFeatureView(item: item)) {
                            SmallCardView(item: item)
                        }
                    }
                }.padding()
            }.onAppear {
                vm.getChangelogs()
            }.navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
