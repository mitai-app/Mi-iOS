//
//  ListView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import FilesProvider

class FTPViewModel: ObservableObject, FileProviderDelegate {
    
    private var provider: FTPFileProvider!
    private var target: Console? {
        return SyncService.shared.target
    }
    private var user: String
    private var password: String
    @State var files: [FileObject] = []
    
    init(user: String = "anonymous", password: String = "anonymous") {
        self.user = user
        self.password = password
    }
    
    func connect() -> Bool {
        print("Attempting to connect")
        if let console = target {
            let urlString = "ftp://\(console.ip):\(console.isPs4 ? 2121 : 21)"
            print(urlString)
            let url = URL(string: urlString)!
            let cred = URLCredential(user: user, password: password, persistence: .forSession)
            self.provider = FTPFileProvider(baseURL: url, mode: .active, credential: cred)!
            self.provider.delegate = self
            return true
        } else {
            return false
        }
    }
    
    private func randomData(size: Int = 262144) -> Data {
        var keyData = Data(count: size)
        let count = keyData.count
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            fatalError("Problem generating random bytes")
        }
    }
    
    func dummyFile() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("dummyfile.dat")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            let data = randomData()
            try! data.write(to: url)
        }
        return url
    }
    
    func getDir() {
        let desc = "Enumerating files list in \(provider.type)"
        print("Test started: \(desc).")
        provider.contentsOfDirectory(path: "/") { (files, error) in
            if let e = error {
                debugPrint(e)
            
            }
            debugPrint("\(files.count) list is empty")
            debugPrint("Files \(files)")
            self.files = files
        }
    }
    
    func uploadFile(_ provider: FileProvider, filePath: String) {
        // test Upload/Download
        let desc = "Uploading file in \(provider.type)"
        print("started: \(desc).")
        let dummy = dummyFile()
        provider.copyItem(localFile: dummy, to: filePath) { (error) in
            print(error ?? "Wtf")
        }
        print("Uploaded.")
    }
    
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        
    }
    
    
}

struct FTPView: View {
    
    @State var show = false
    
    @StateObject var sync: SyncService
    
    @StateObject var vm: FTPViewModel = FTPViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Consoles")
            
                List {
                    ForEach(vm.files) { item in
                        ListItem(file: item)
                    }
                }.refreshable {
                    debugPrint("Doing the connecting thing")
                    if vm.connect() {
                        debugPrint("Connected?")
                        vm.getDir()
                    } else {
                        debugPrint("Could not connect")
                    }
                }
            .navigationTitle("Consoles")
            }
            .onAppear {
                debugPrint("Doing the connecting thing")
                if vm.connect() {
                    debugPrint("Connected?")
                    vm.getDir()
                } else {
                    debugPrint("Could not connect")
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        FTPView(sync: SyncService.test())
    }
}


extension FileObject: Identifiable {
    public var id: Int {
        return self.hash
    }
}
