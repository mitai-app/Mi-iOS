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
    
    @Published var results: [PackageModel] = []
    @Published var response: PackageResponse?
    
    init() {}
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func searchPackages(search: String) {
        Package.searchBin(search: search) { [weak self] response in
            self?.response = response
        }
    }
    
    
    func searchPackages(find: String) {
        if (response != nil) {
            let result  = response!.packages.filter { model in
                model.name.contains(find) || model.author.contains(find)
            }
            self.results = result
        }
    }
    func startDownload(_ console: Console, _ model: PackageModel, _ version: String, _ link: String) {
        print("Downloading \(model.name): \(model.version) - \(version)")
        SyncService.psx.getRequest(url: link) { res in
            do {
                if let data = try res.result.get() {
                    print("Downloaded \(model.name): \(model.version) - \(version)")
                    DispatchQueue.global().async {
                        print("Connecting to goldenhen via \(console.ip) and sending payload")
                        if Goldhen.uploadData(data: data) {
                            DispatchQueue.main.async {
                                print("Uploaded to goldenhen \(model.name): \(model.version) - \(version)")
                            }
                        }
                    }
                }
            } catch {
                print("Error downloading \(model.name): \(model.version) - \(version)")
                debugPrint(error)
            }
        }
    }
    
}

struct PackageView: View {
    
    @State var show = false
    @State var search = ""
    @State var source = ""
    
    @EnvironmentObject var sync: SyncService
    @State var background: Color
    @State var showingOptions: Bool = false
    @State var showingAlert: Bool = false
    
    @StateObject var vm: PackageViewModel = PackageViewModel()
    
    
    
    var body: some View {
        CustomNavView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        HStack {
                            TextField("", text: $search)
                                .placeholder(when: search.isEmpty) {
                                    Text("Search packages...").foregroundColor(Color.gray)
                                }
                                .padding(12)
                                .background(Color("grayDark"))
                                .cornerRadius(8)
                            
                                .onChange(of: search) { newValue in
                                        vm.searchPackages(find: newValue)
                                }.foregroundColor(.white)
                                .accentColor(.red)
                            .shadow(color: Color.black.opacity(0.7), radius: 1, x:0, y:1)
                            .padding(Edge.Set.trailing, 8)
                            Spacer()
                            Button(action: {
                                showingAlert.toggle()
                            }, label: {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }).foregroundColor(.brown)
                                .alert("Source", isPresented:$showingAlert, actions: {
                                    TextField("Repo url", text: $source)
                                    Button("Add", action: {})
                                    Button("Cancel", role: .cancel, action: {})
                                }, message: {
                                    Text("Add a repository")
                                })
                            
                        }
                    }
                    
                    if SyncService.shared.target?.isPs4 == true {
                        GoldhenBinView(vm: GoldhenBinViewModel(console: SyncService.shared.target!))
                    }
                    
                    if vm.response != nil && search.isEmpty {
                        RepoListItem(response: vm.response!)
                    } else if !vm.results.isEmpty {
                            ForEach(vm.results) { item in
                            PackageViewItem(package: item)
                                .actionSheet(isPresented: $showingOptions) {
                                    if SyncService.shared.target == nil || !(SyncService.shared.target?.isPs4 == true) {
                                        var buttons = SyncService.shared.getPotentialClients().filter{ $0.isPs4 } .map { console in
                                            Alert.Button.default(Text("\(console.type.title): \(console.ip)")) {
                                                SyncService.shared.target = console
                                            }
                                        }
                                        buttons.append(
                                            .destructive(Text("Close"))
                                        )
                                        return ActionSheet(
                                            title: Text("Console"),
                                            message: Text("Please select a target"),
                                            buttons: buttons
                                        )
                                    } else {
                                        var buttons = item.dl.compactMap { (key: String, value: String) in
                                            Alert.Button.default(Text("\(key)")) {
                                                vm.startDownload(SyncService.shared.target!, item, key, value)
                                            }
                                        }
                                        
                                        buttons.append(.destructive(Text("Close")))
                                        
                                        return ActionSheet(
                                            title: Text("\(item.name) versions"),
                                            message: Text("Download version to your ps4"),
                                            buttons: buttons
                                        )
                                    }
                            }.onTapGesture(perform: {
                                print("clicked")
                                showingOptions.toggle()
                            })
                            
                        }
                        
                    } else if vm.verifyUrl(urlString: search) {
                        Button(action: {
                            showingAlert.toggle()
                        }, label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }).foregroundColor(.brown)
                        
                    } 
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
        PackageView(background: Color("quinary"))
            .environmentObject( SyncService.test())
        PackageViewItem(package: PackageModel(
            name: "GoldHen",
            author: "SiStRo",
            version: "2.2.4",
            type: PackageType.plugin,
            icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
            link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
            dl: [:]))
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


class RepoListItemViewModel: ObservableObject {
    
    init() {}
    
    
    func startDownload(_ console: Console, _ model: PackageModel, _ version: String, _ link: String) {
        print("Downloading \(model.name): \(model.version) - \(version)")
        SyncService.psx.getRequest(url: link) { res in
            do {
                if let data = try res.result.get() {
                    print("Downloaded \(model.name): \(model.version) - \(version)")
                    DispatchQueue.global().async {
                        print("Connecting to goldenhen via \(console.ip) and sending payload")
                        if Goldhen.uploadData(data: data) {
                            DispatchQueue.main.async {
                                print("Uploaded to goldenhen \(model.name): \(model.version) - \(version)")
                            }
                        }
                    }
                }
            } catch {
                print("Error downloading \(model.name): \(model.version) - \(version)")
                debugPrint(error)
            }
        }
    }
}

struct RepoListItem: View {
    
    var response: PackageResponse

    @StateObject var vm: RepoListItemViewModel = RepoListItemViewModel()
    
    @State var showingOptions: Bool = false
    @State var showingTargets: Bool = false
    
    @State var selectionKey: String = ""
    @State var selectionValue: String = ""
    @State var selectionModel: PackageModel!
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                KFImage(URL(string: response.banner))
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
                }.padding()
            }
            ForEach(response.packages) { item in
                PackageViewItem(package: item)
                    .actionSheet(isPresented: $showingOptions) {
                        if SyncService.shared.target == nil || !(SyncService.shared.target?.isPs4 == true) {
                            var buttons = SyncService.shared.getPotentialClients().filter{ $0.isPs4 } .map { console in
                                Alert.Button.default(Text("\(console.type.title): \(console.ip)")) {
                                    SyncService.shared.target = console
                                }
                            }
                            buttons.append(
                                .destructive(Text("Close"))
                            )
                            return ActionSheet(
                                title: Text("Console"),
                                message: Text("Please select a target"),
                                buttons: buttons
                            )
                        } else {
                            var buttons = item.dl.compactMap { (key: String, value: String) in
                                Alert.Button.default(Text("\(key)")) {
                                    selectionKey = key
                                    selectionValue = value
                                    selectionModel = item
                                    vm.startDownload(SyncService.shared.target!, selectionModel, selectionKey, selectionValue)
                                    
                                }
                            }
                            
                            buttons.append(.destructive(Text("Close")))
                            
                            return ActionSheet(
                                title: Text("\(item.name) versions"),
                                message: Text("Download version to your ps4"),
                                buttons: buttons
                            )
                        }
                }.onTapGesture(perform: {
                    print("clicked")
                    showingOptions.toggle()
                })
                
            }
        }.frame(maxWidth: .infinity).background(.white).cornerRadius(8)
    }
}
