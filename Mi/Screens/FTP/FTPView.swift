//
//  ListView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import FilesProvider

class FTPViewModel: ObservableObject, FTPDelegate {
    
    func onList(dirs: [FTPFile]) {
        self.dir = dirs
    }
    
    
    private var target: Console? {
        return SyncServiceImpl.shared.target
    }
    
    @Published var ftp: FTP!
    @Published var dir: [FTPFile] = []
    
    private var user: String
    private var password: String
    
    init(user: String = "anonymous", password: String = "anonymous") {
        self.user = user
        self.password = password
    }
    
    func connect() -> Bool {
        print("Attempting to connect")
        if(SyncServiceImpl.shared.connectFtp()) {
            ftp = SyncServiceImpl.shared.ftp[target!.ip]
            self.ftp.delegate = self
            return ftp.list()
        }
        return false
    }
   
    func getDir() {
        ftp?.list()
    }
    
}

struct FTPView: View {
    
    @State var show = false
    
    @EnvironmentObject var sync: SyncServiceImpl
    
    @StateObject var vm: FTPViewModel = FTPViewModel()
    
    var body: some View {
        CustomNavView {
            VStack (spacing: 0) {
                List {
                ForEach(vm.dir) { item in
                    ListItem(file: item)
                }
                }.refreshable {
                    debugPrint("Doing the connecting thing")
                    if vm.connect() {
                        debugPrint("Connected?")
                    } else {
                        debugPrint("Could not connect")
                    }
                }
            }.customNavigationTitle("FTP")
            .customNavigationBarBackButtonHidden(true)
            .onPreferenceChange(TabBarItemSelectedPreferenceKey.self) { item in
                print(item)
                switch item {
                case .ftp:
                    vm.connect()
                    break
                default:
                        break
                }
            }
            .onAppear {
                debugPrint("Doing the connecting thing")
                if vm.connect() {
                    debugPrint("Connected?")
                } else {
                    debugPrint("Could not connect")
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        FTPView().environmentObject(SyncServiceImpl.test())
    }
}


extension FileObject: Identifiable {
    public var id: Int {
        return self.hash
    }
}
