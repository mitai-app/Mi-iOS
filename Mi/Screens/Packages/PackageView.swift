//
//  PackageView.swift
//  Mi
//
//  Created by Vonley on 9/30/22.
//

import SwiftUI
import UIKit
import Kingfisher

class PackageViewModel: ObservableObject {
    
    
    private var target: Console? {
        return SyncServiceImpl.shared.target
    }
    
    @Published var results: [PackageModel] = []
    @Published var response: [PackageResponse] = []
    
    init() {
        searchPackages(search: "https://raw.githubusercontent.com/mitai-app/versioning/main/packages.json")
    }
    
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
        }
    }
    
    func addSource(source: String, onResponse: @escaping (PackageResponse) -> Void) {
        Package.findRepo(url: source) { response in
            self.response.append(response)
            onResponse(response)
        } onError: { error in
            debugPrint(error)
        }
    }
    
    func searchPackages(find: String) {
        let result  = self.response.flatMap { model in model.packages}.filter { package in
            package.name.localizedCaseInsensitiveContains(find) || package.author.localizedCaseInsensitiveContains(find)
        }
        self.results = result
    }
    
    func searchPackages(find: FetchedResults<RepositoryEntity>) {
        find.forEach { entity in
            if let link = entity.link {
                searchPackages(search: link)
            }
        }
    }
    
    func startDownload(_ console: Console, _ model: PackageModel, _ version: String, _ link: String) {
        print("Downloading \(model.name): \(model.version) - \(version)")
        SyncServiceImpl.psx.getRequest(url: link) { res in
            Task(priority: .background) {
                do {
                    if let data = try res.result.get() {
                        print("Downloaded \(model.name): \(model.version) - \(version)")
                        print("Connecting to goldenhen via \(console.ip) and sending payload")
                        if await Goldhen.uploadData(data: data) {
                            await MainActor.run {
                                print("Uploaded to goldenhen \(model.name): \(model.version) - \(version)")
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
    
}

struct PackageView: View {
    
    @State var show = false
    @State var search = ""
    @State var source = ""
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject var sync: SyncServiceImpl
    @State var showingAlert: Bool = false
    
    @FetchRequest<RepositoryEntity>(
        entity: RepositoryEntity.entity(),
        sortDescriptors: []
    ) var savedEntities: FetchedResults<RepositoryEntity>
    
    
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
                vm.searchPackages(find: savedEntities)
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
                    alertMessage(
                        title: "Enter repo url",
                        message: "Add a repository",
                        placeholder: "repository url here",
                        onConfirm: { string in
                            if string.verifyUrl() {
                                vm.addSource(source: string) { response in
                                    do {
                                        var repo = RepositoryEntity(context: moc)
                                        repo.link = string
                                        try moc.save()
                                    } catch {
                                        print("unable to save")
                                    }
                                }
                            }
                        }) {
                            // do nothing
                        }
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }).foregroundColor(Color("navcolor"))
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
