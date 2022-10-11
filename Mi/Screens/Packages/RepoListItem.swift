//
//  RepoListItem.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import SwiftUI
import Kingfisher

class RepoListItemViewModel: ObservableObject {
    
    init() {}
    
}

struct RepoListItem: View {
    
    var response: PackageResponse

    @State var showPayloads: Bool = false
    @StateObject var vm: RepoListItemViewModel = RepoListItemViewModel()
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                KFImage(URL(string: response.banner))
                    .placeholder {
                        Image("play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    }.blur(radius: 2.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(response.title) (\(response.packages.count) pkgs)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(alignment: .leading)
                    Text("\(response.description)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("secondary"))
                        .frame(alignment: .leading)
                    Text("Author: \(response.author)")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .frame(alignment: .leading)
                        .dynamicTypeSize(.xSmall)
                }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Color("background").opacity(0.2))
            }.cornerRadius(30).onTapGesture {
                withAnimation(Animation.easeInOut(duration: 0.5)) {
                    showPayloads.toggle()
                }
            }
            if showPayloads {
                PackageListView(packages: response.packages)
            }
        }
    }
}

struct RepoListItem_Previews: PreviewProvider {
    static var previews: some View {
        let response = PackageResponse(title: "Title", author: "Author", banner: "Banner", description: "Description", packages: [PackageModel(
            name: "GoldHen",
            author: "SiStRo",
            version: "2.2.4",
            type: PackageType.plugin,
            icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
            link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
            dl: [:])])
        RepoListItem(response: response)
    }
}
