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
        return SyncServiceImpl.shared.target
    }
    
    @Published var results: [PackageModel] = []
    @Published var response: [PackageResponse] = []
    
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
            self?.response.append(response)
            self?.response.append(PackageResponse(title: "Title", author: "Author", banner: "Banner", description: "Description", packages: [PackageModel(
                name: "GoldHen",
                author: "SiStRo",
                version: "2.2.4",
                type: PackageType.plugin,
                icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
                link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
                dl: [:])], lastUpdated: ""))
        }
    }
    
    
    func searchPackages(find: String) {
        let result  = self.response.flatMap { model in model.packages}.filter { package in
            package.name.localizedCaseInsensitiveContains(find) || package.author.localizedCaseInsensitiveContains(find)
        }
        self.results = result
    }
    func startDownload(_ console: Console, _ model: PackageModel, _ version: String, _ link: String) {
        print("Downloading \(model.name): \(model.version) - \(version)")
        SyncServiceImpl.psx.getRequest(url: link) { res in
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
    
    @EnvironmentObject var sync: SyncServiceImpl
    @State var showingAlert: Bool = false
    
    @StateObject var vm: PackageViewModel = PackageViewModel()
    
    var body: some View {
        CustomNavView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    textFieldView
                    if search.isEmpty {
                        ForEach(vm.response) { repo in
                            RepoListItem(response: repo)
                        }
                    } else if !vm.results.isEmpty {
                        PackageListView(packages: vm.results)
                    } else if vm.verifyUrl(urlString: search) {
                        
                    } 
                }.padding(20)
            }
            .refreshable {
                        
            }.customNavigationTitle("Packages")
            .customNavigationBarBackButtonHidden(true)
            .onAppear {
                vm.searchPackages(search: search)
            }
        }
    }
}

extension PackageView {
    
    var textFieldView: some View {
        VStack {
            HStack {
                TextField("", text: $search)
                    .placeholder(when: search.isEmpty) {
                        Text("Search packages...").foregroundColor(Color.gray)
                    }
                    .padding(12)
                    .background(Color("background"))
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
                }).foregroundColor(Color("navcolor"))
                    .alert("Source", isPresented:$showingAlert, actions: {
                        TextField("Repo url", text: $source)
                        Button("Add", action: {})
                        Button("Cancel", role: .cancel, action: {})
                    }, message: {
                        Text("Add a repository")
                    })
                
            }
        }
    }
    
    
    
}
struct PackageView_Previews: PreviewProvider {
    static var previews: some View {
        PackageView()
            .environmentObject(SyncServiceImpl.test())
        
        
        PackageView()
            .environmentObject(SyncServiceImpl.test()).colorScheme(.dark)
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
