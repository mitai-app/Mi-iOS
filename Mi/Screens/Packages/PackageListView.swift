//
//  RepoPackageListView.swift
//  Mi
//
//  Created by Vonley on 10/6/22.
//

import SwiftUI

class RepoPackageListViewModel: ObservableObject {
    init() {}
    
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

struct PackageListView: View {
    let packages: [PackageModel]
    
    @State var showingOptions: Bool = false
    @State var showingTargets: Bool = false
    
    
    @State var selectionKey: String = ""
    @State var selectionValue: String = ""
    @State var selectionModel: PackageModel!
    @EnvironmentObject var sync: SyncServiceImpl
    
    @StateObject var vm: RepoPackageListViewModel = RepoPackageListViewModel()
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            ForEach(packages) { item in
                PackageViewItem(package: item)
                    .actionSheet(isPresented: $showingOptions) {
                        return getActionSheet(item: item)
                    }
                    .onTapGesture(perform: {
                        print("clicked")
                        showingOptions.toggle()
                    })
            }
        }
   
    }
}
extension PackageListView {
    
    func getActionSheet(item: PackageModel) -> ActionSheet {
        if sync.target == nil || !(sync.target?.isPs4 == true) {
            var buttons = sync.getPotentialClients().filter{ $0.isPs4 } .map { console in
                Alert.Button.default(Text("\(console.type.title): \(console.ip)")) {
                    sync.target = console
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
                    vm.startDownload(sync.target!, item, key, value)
                }
            }
            
            buttons.append(.destructive(Text("Close")))
            
            return ActionSheet(
                title: Text("\(item.name) versions"),
                message: Text("Download version to your ps4"),
                buttons: buttons
            )
        }
    }
    
    
}
struct RepoPackageListView_Previews: PreviewProvider {
    static var previews: some View {
        let response = PackageResponse(title: "Title", author: "Author", banner: "Banner", description: "Description", packages: [PackageModel(
        name: "GoldHen",
        author: "SiStRo",
        version: "2.2.4",
        type: PackageType.plugin,
        icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
        link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
        dl: [:])])
        PackageListView(packages: response.packages)
    }
}
