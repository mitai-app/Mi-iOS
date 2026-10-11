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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                textFieldView
                if search.isEmpty {
                    if vm.response.isEmpty {
                        emptyState
                    } else {
                        ForEach(vm.response) { repo in
                            RepoListItem(response: repo)
                        }
                    }
                } else if !vm.results.isEmpty {
                    VStack(spacing: 0) {
                        PackageListView(packages: vm.results)
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    noResultsState
                }
            }
            .padding(16)
        }.onAppear {
            vm.searchPackages(find: savedEntities)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "shippingbox")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("No packages yet")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Add a repository to browse and install payloads.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(action: addRepository) {
                Label("Add repository", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color("navcolor"))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var noResultsState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("No results for \u{201C}\(search)\u{201D}")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func addRepository() {
        alertMessage(
            title: "Add repository",
            message: "Enter a repository URL",
            placeholder: "https://.../packages.json",
            onConfirm: { string in
                if string.verifyUrl() {
                    vm.addSource(source: string) { _ in
                        do {
                            let repo = RepositoryEntity(context: moc)
                            repo.link = string
                            try moc.save()
                        } catch {
                            print("unable to save")
                        }
                    }
                }
            }) {
                // cancelled
            }
    }
}

extension PackageView {

    
    var textFieldView: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search packages", text: $search)
                    .foregroundColor(.primary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: search) { _, newValue in
                        vm.searchPackages(find: newValue)
                    }
                if !search.isEmpty {
                    Button {
                        search = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: addRepository) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color("navcolor"))
            }
            .accessibilityLabel("Add repository")
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
