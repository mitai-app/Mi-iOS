//
//  ChangelogSectionView.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import SwiftUI

class ChangelogViewModel: ObservableObject {
    
    @Published var changes: [Changes] = []
    
    init() {
        
    }
    
    func setChanges(change: Changelog) {
        self.changes = change.changelogs
    }
    
}


struct ChangelogSectionView: View {
    
    let change: Changelog
    @StateObject var vm = ChangelogViewModel()
    
    var body: some View {
        Text("Changelogs")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
        ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 16) {
                            ForEach(vm.changes) { item in
                                CustomNavLink(destination:
                                                ChangelogFeatureView(changelog: change, item: item)
                                                .customNavigationTitle("Changelogs")
                                                .customNavigationSubtitle("Recent Improvements")
                                                .customNavigationBarBackButtonHidden(false)
                                ) {
                                    ChangelogCardView(item: item)
                                }
                            }
                    }
                    .padding()
        }.onAppear {
            vm.setChanges(change: change)
        }
        
    }
}

struct ChangelogSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogSectionView(change: fakeChangeLogs[0])
    }
}
