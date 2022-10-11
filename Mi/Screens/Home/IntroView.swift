//
//  IntroView.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import Foundation
import SwiftUI
import Kingfisher

class IntroViewModel: ObservableObject {
    
    @Published var articles: [Article] = Constants.ARTICLES
    
    @Published var changelogs: Changelog? = nil
    
    
    func getChangelogs() {
        Package.getMeta { response in
            self.changelogs = response
        }
    }
}

struct IntroView: View {
    
    @EnvironmentObject var sync: SyncServiceImpl
    @Environment(\.openURL) private var openURL
    @StateObject private var vm: IntroViewModel = IntroViewModel()
    
    var body: some View {
        CustomNavView {
            ScrollView {
                ForEach(0..<vm.articles.count) { index in
                    ArticleView(article: vm.articles[index])
                }
                
                LogView(logs: $sync.logs)
                    .foregroundColor(Color("foreground"))
                
                if let change = vm.changelogs {
                    ChangelogSectionView(change: change)
                        .foregroundColor(Color("foreground"))
                }
            }.onAppear {
                vm.getChangelogs()
            }.customNavigationTitle("Home")
                .customNavigationBarBackButtonHidden(true)
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
            .environmentObject(SyncServiceImpl.test())
        IntroView()
            .environmentObject(SyncServiceImpl.test()).colorScheme(.dark)
    }
}

