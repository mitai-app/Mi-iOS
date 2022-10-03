//
//  PackageView.swift
//  Mi
//
//  Created by Vonley on 9/30/22.
//

import SwiftUI
import FilesProvider
import Kingfisher

class PackageViewModel: ObservableObject {
    
    private var target: Console? {
        return SyncService.shared.target
    }
    
    @Published var response: PackageResponse?
    
    init() {}
    
    func searchPackages(search: String) {
        Package.searchBin(search: search) { [weak self] response in
            self?.response = response
        }
    }
    
}

struct PackageView: View {
    
    @State var show = false
    @State var search = ""
    
    @StateObject var sync: SyncService
    @State var background: Color
    
    @StateObject var vm: PackageViewModel = PackageViewModel()
    
    
    
    var body: some View {
        CustomNavView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        TextField("", text: $search)
                            .placeholder(when: search.isEmpty) {
                                Text("Enter url...").foregroundColor(Color.gray)
                            }
                            .padding()
                            .background(Color("grayDark"))
                            .cornerRadius(8)
                        
                            .onChange(of: search) { newValue in
                                    vm.searchPackages(search: newValue)
                            }.foregroundColor(.white)
                            .accentColor(.red)
                            .shadow(color: Color.black.opacity(0.7), radius: 1, x:0, y:1)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if vm.response != nil {
                            ZStack {
                                KFImage(URL(string: vm.response!.banner))
                                    .placeholder {
                                            Image(systemName: "paperplane.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 50)
                                                .frame(maxWidth: 50)
                                                .padding()
                                    }.blur(radius: 2.0)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                VStack(alignment: .center, spacing: 4) {
                                    Text("\(vm.response!.title) (\(vm.response!.packages.count) pkgs)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                    Text("\(vm.response!.description)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("secondary"))
                                        .frame(alignment: .leading)
                                    Text("Author: \(vm.response!.author)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                        .frame(alignment: .leading)
                                        .dynamicTypeSize(.xSmall)
                                }.padding()
                            }
                            ForEach(vm.response!.packages) { item in
                                PackageViewItem(package: item)
                            }
                        }
                    }.frame(maxWidth: .infinity).background(.white).cornerRadius(8)
                }.padding(20)
            }
            .background(background)
            .refreshable {
                    
            }.customNavigationTitle("Packages")
            .customNavigationBarBackButtonHidden(true)
            .onAppear {
                vm.searchPackages(search: search)
            }
        }
    }
}


struct PackageView_Previews: PreviewProvider {
    static var previews: some View {
        PackageView(sync: SyncService.test(), background: Color("quinary"))
        PackageViewItem(package: PackageModel(
            name: "GoldHen",
            author: "SiStRo",
            version: "2.2.4",
            type: PackageType.plugin,
            icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
            link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true"))
    }
}


extension View {
    func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content) -> some View {

            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

struct PackageViewItem: View {
    
    var package: PackageModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                KFImage(URL(string: package.icon))
                    .placeholder {
                            Image(systemName: "paperplane.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .frame(maxWidth: 50)
                                .padding()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .frame(maxWidth: 50)
                    .padding()
                    
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(package.name) \(package.type.rawValue) by \(package.author)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .dynamicTypeSize(DynamicTypeSize.small)
                        .foregroundColor(Color("tertiary"))
                        
                    Text("ver: \(package.version)")
                        .foregroundColor(.gray)
                        .dynamicTypeSize(DynamicTypeSize.small)
                }
                Spacer()
            }
        }
    }
}
