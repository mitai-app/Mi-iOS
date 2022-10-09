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
                    ExtractedView(article: vm.articles[index])
                }
                if let change = vm.changelogs {
                    ChangelogSectionView(change: change)
                        .foregroundColor(.white)
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

struct ExtractedView: View {
    
    @Environment(\.openURL) private var openURL
    
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let desc = article.description {
                    Text(desc)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(30)
            ZStack(alignment: .bottom) {
                if let img = article.icon {
                    ZStack {
                        if img.verifyUrl() {
                            KFImage(URL(string: img))
                                .placeholder {
                                    Image(systemName: "money")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(.white)
                        } else {
                            Image(img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(.white)
                        }
                    }.frame(maxHeight: 240).blur(radius: 1)
                }
            }
            .cornerRadius(20)
            .frame(alignment: .leading)
        }
        .background(article.background)
        .foregroundColor(.white)
        .cornerRadius(20)
        .padding()
        .onTapGesture {
            if article is BasicViewType {
                
            } else if article is ProfileViewType {
                
            } else if article is PayloadViewType {
                
            } else if article is ReadableViewType {
                
            }
            
            if let link = article.link {
                if let url = URL(string: link) {
                    UIApplication.shared.open(url, options: [.universalLinksOnly: true])
                }
            }
        }
    }
}
