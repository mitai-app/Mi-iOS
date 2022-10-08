//
//  ListView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import FilesProvider
import Foundation

class FTPViewModel: ObservableObject, FTPDelegate {
    
    init () {
        ftp.delegate = self
    }
    
    func onFileSaved(action: ActionData) {
        debugPrint("recieved \(action)")
        delegate?.onFileSaved(action: action)
    }
    
    
    @Published var dir: [FTPFile] = []
    private var target: Console? {
        return SyncServiceImpl.shared.target
    }
    
    private var ftp: FTP = FTP.shared
    var delegate: FTPDelegate?
    private var cancellable: Any!
    
    
    func onList(dirs: [FTPFile]) {
        self.dir = dirs
        debugPrint("recieved in vm: \(dirs.count)")
        self.objectWillChange.send()
        delegate?.onList(dirs: dirs)
    }
    
    func delete(file: FTPFile) async -> Bool {
        let a = await ftp.delete(filename: file.name)
        try? await Task.sleep(nanoseconds: 100_000_00)
        let b = await ftp.list()
        return a && b
    }
    
    func connect() async -> Bool {
        debugPrint("Attempting to connect")
        if await SyncServiceImpl.shared.connectFtp()  {
            return await ftp.list()
        }
        return false
    }
   
    func changeDir(file: FTPFile) async -> Bool {
        if file.directory {
            await ftp.cwd(dir: file.name)
            try? await Task.sleep(nanoseconds: 100_000_000)
            await ftp.pwd()
            try? await Task.sleep(nanoseconds: 100_000_000)
            await ftp.list()
            return true
        }
        return false
    }
    
    func getDir() async -> Bool {
        return await ftp.list()
    }
    
}

struct FTPView: View, FTPDelegate {
    
    func onFileSaved(action: ActionData) {
        let dir = getDocumentsDirectory()
            
        let url = dir.appendingPathComponent(URL(string: action.name)!.lastPathComponent)
        
        do {
            try action.data.write(to: url, options: Data.WritingOptions.atomic)
            //try action.data.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            print(input)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func onList(dirs: [FTPFile]) {
        vm.objectWillChange.send()
        debugPrint("recieved in vm: \(dirs.count)")
    }
    @State var isImporting = false
    @State var show: Bool = false
    @State var input: String = ""
    
    @EnvironmentObject var sync: SyncServiceImpl
    
    @StateObject private var document: InputDoument = InputDoument()
    @StateObject var ftp: FTP = FTP.shared
    @StateObject var vm: FTPViewModel = FTPViewModel()
    
    var body: some View {
        CustomNavView {
            VStack (spacing: 0) {
                HStack {
                    Text("CWD: \(ftp.cwd)")
                        .font(.title3)
                        .foregroundColor(Color("foreground"))
                        .fontWeight(.bold)
                    Spacer()
                    
                    Menu {
                        Button {
                            print("Upload File")
                            withAnimation(.default) {
                                isImporting.toggle()
                            }
                        } label: {
                            Label("New File", systemImage: "doc.badge.plus")
                        }
                    
                        Button {
                            print("New Folder")
                            withAnimation(.default) {
                                show.toggle()
                            }
                        } label: {
                            Label("New Folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName:  "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }.foregroundColor(Color("navcolor"))
                }.padding()
                List {
                    ForEach($ftp.dir) { item in
                        withAnimation(.easeInOut(duration: 1.0)) {
                            ListItem(file: item)
                                .contextMenu {
                                    if !item.wrappedValue.directory {
                                        Button {
                                            print("Download File")
                                            Task {
                                                await ftp.download(filename: item.wrappedValue)
                                            }
                                        } label: {
                                            Label("Download File", systemImage: "arrow.down.doc")
                                        }
                                    }
                                    
                                    Button {
                                        Task {
                                            await vm.delete(file: item.wrappedValue)
                                        }
                                    } label: {
                                        Label("Delete \(item.wrappedValue.directory ? "Folder" : "File")", systemImage: "\(item.wrappedValue.directory ? "folder.badge.minus" : "doc.badge.minus")")
                                    }
                                }
                                .onTapGesture {
                                    Task {
                                        await vm.changeDir(file: item.wrappedValue)
                                    }
                                }
                        }
                    }
                }.refreshable {
                    Task {
                        debugPrint("Doing the connecting thing")
                        if await vm.connect() {
                            debugPrint("Connected?")
                        } else {
                            debugPrint("Could not connect")
                        }
                    }
                }.fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: InputDoument.readableContentTypes,
                    allowsMultipleSelection: true,
                    onCompletion: { result in
                        do {
                            Task {
                                for selectedFile in try result.get() {
                                    print("uploading \(selectedFile.lastPathComponent)")
                                    await ftp.upload(filename: selectedFile)
                                }
                            }
                        } catch {
                            // Handle failure.
                            print("Unable to read file contents")
                            print(error.localizedDescription)
                        }
                    }
                )
                .textFieldAlert(isShowing: $show, text: $input, title: "Create")
            }.customNavigationTitle("FTP")
            .customNavigationBarBackButtonHidden(true)
            .onPreferenceChange(TabBarItemSelectedPreferenceKey.self) { item in
                Task {
                    print(item)
                    switch item {
                    case .ftp:
                        await vm.connect()
                        break
                    default:
                            break
                    }
                }
            }
            .onAppear {
                vm.delegate = self
                debugPrint("Doing the connecting thing")
                Task {
                    if await vm.connect() {
                        debugPrint("Connected?")
                    } else {
                        debugPrint("Could not connect")
                    }
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

struct TextFieldAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(isShowing)
                VStack {
                    Text(self.title)
                    TextField(self.title, text: self.$text).padding()
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isShowing.toggle()
                            }
                        }) {
                            Text("Dismiss")
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .opacity(self.isShowing ? 1 : 0)
                .shadow(color: .black, radius: 1, x: 0, y: 2)
            }
        }
    }

}

extension View {

    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title)
    }

}
