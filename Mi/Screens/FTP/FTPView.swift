//
//  ListView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import Foundation

class FTPViewModel: ObservableObject, FTPDelegate {
    
    init () {
        ftp.delegate = self
    }
    
    private var ftp: FTP = FTP.shared
    var delegate: FTPDelegate?
    private var cancellable: Any!
    
    @Published var dir: [FTPFile] = []
    @Published var cwd: String = ""
    
    private var target: Console? {
        return SyncServiceImpl.shared.target
    }
    func delete(file: FTPFile) async -> Bool {
        return await ftp.delete(file: file)
    }
    func download(file: FTPFile) async -> Bool {
        return await ftp.download(filename: file)
    }
    
    func upload(url: URL) async -> Bool {
        return await ftp.upload(filename: url)
    }
    
    func connect() async -> Bool {
        return await SyncServiceImpl.shared.connectFtp()
    }
   
    func changeDir(file: FTPFile) async -> Bool {
        return await ftp.changeDir(file: file)
    }
    
    func getDir() async -> Bool {
        return await ftp.getCurrentDir()
    }
    
    func onList(dirs: [FTPFile]) {
        self.dir = dirs
        self.cwd = dirs[0].cwd
        debugPrint("recieved in vm: \(dirs.count)")
        self.objectWillChange.send()
        delegate?.onList(dirs: dirs)
    }
    
    func makeDir(dir: String) async -> Bool {
        return await ftp.createDir(dir: dir)
    }
    
    func onFileSaved(action: ActionData) {
        debugPrint("recieved \(action)")
        let dir = getDocumentsDirectory()
            
        let url = dir.appendingPathComponent(URL(string: action.name)!.lastPathComponent)
        
        do {
            try action.data.write(to: url, options: Data.WritingOptions.atomic)
            //try action.data.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            
            #if DEBUG
            if input.contains("content") && input.contains(""){
                debugPrint(input)
            }
            #endif
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
    
}

struct FTPView: View {
    
    @State var isImporting = false
    @State var show: Bool = false
    @State var input: String = ""
    
    @EnvironmentObject var sync: SyncServiceImpl
    
    @StateObject private var document: InputDoument = InputDoument()
    @StateObject var vm: FTPViewModel = FTPViewModel()
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text("CWD: \(vm.cwd)")
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
                        alertMessage(
                            title: "Create",
                            message: "Create new folder",
                            placeholder: "folder name",
                            onConfirm: { string in
                                Task(priority: .background) {
                                    await vm.makeDir(dir: string)
                                }
                            }) {
                                // do nothing
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
                ForEach($vm.dir) { item in
                    ListItem(file: item)
                        .contextMenu {
                            if !item.wrappedValue.directory {
                                Button {
                                    Task(priority: .background) {
                                        print("Downloading \(item.wrappedValue.name)")
                                        await vm.download(file: item.wrappedValue)
                                    }
                                } label: {
                                    Label("Download File", systemImage: "arrow.down.doc")
                                }
                            }
                            
                            Button {
                                Task(priority: .background) {
                                    await vm.delete(file: item.wrappedValue)
                                }
                            } label: {
                                Label("Delete \(item.wrappedValue.directory ? "Folder" : "File")", systemImage: "delete.left")
                            }
                        }
                        .onTapGesture {
                            Task(priority: .background) {
                                await vm.changeDir(file: item.wrappedValue)
                            }
                        }
                }
            }.refreshable {
                Task(priority: .background) {
                    if await vm.connect() {
                        #if DEBUG
                        debugPrint("Connected?")
                        #endif
                    } else {
                        #if DEBUG
                        debugPrint("Could not connect")
                        #endif
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: InputDoument.readableContentTypes,
                allowsMultipleSelection: true,
                onCompletion: { result in
                    Task {
                        for selectedFile in try result.get() {
                            print("uploading \(selectedFile.lastPathComponent)")
                            await vm.upload(url: selectedFile)
                        }
                    }
                }
            )
            .textFieldAlert(isShowing: $show, text: $input, title: "Create")
        }.customNavigationTitle("FTP")
        .customNavigationBarBackButtonHidden(true)
        .onAppear {
            Task(priority: .background) {
                if await vm.connect() {
                    #if DEBUG
                    debugPrint("Connected?")
                    #endif
                } else {
                    #if DEBUG
                    debugPrint("Could not connect")
                    #endif
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
