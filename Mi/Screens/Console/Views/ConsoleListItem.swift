//
//  ConsoleListItem.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI



struct ConsoleListItem: View {
    var console: Console
    @State var show: Bool = false
    @EnvironmentObject var sync: SyncServiceImpl
    
    @StateObject private var document: InputDoument = InputDoument()
    @State private var isImporting: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    if console.isPs4 || console.isPs3 {
                        Image(systemName: sync.target?.ip == console.ip ? "target" : "antenna.radiowaves.left.and.right.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                        
                    } else {
                        Image(systemName: "network")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                }
                .padding(4)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(console.name) - \(console.ip)")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(console.features.commaSeperated())
                        .bold()
                        .dynamicTypeSize(DynamicTypeSize.xSmall)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(8)
            }.padding(.horizontal)
            if show && console.isPs3 {
                ConsoleFeatureView(item: console)
            }
        }.onTapGesture {
            sync.target = console
        }
        .foregroundColor(sync.target?.ip == console.ip ? Color("quaternary") : Color.gray)
        .contextMenu(menuItems: {
            Button {
                sync.target = console
                SyncServiceImpl.shared.findDevice(ip: console.ip) { console in
                    AlertHelper.alert(title: "Success", message: "Console rescanned") { action in
                        
                    }
                } onError: { error in
                    AlertHelper.alert(title: "Error", message: error) { action in
                        
                    }
                }
            } label: {
                Label("Rescan", systemImage: "arrow.clockwise.circle")
            }
            if console.isPs3 {
                Button {
                    sync.target = console
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        show.toggle()
                    }
                } label: {
                    Label(show ? "Collapse" : "Expand", systemImage: show ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                }
            }
            if console.isPs4 {
                Button {
                    sync.target = console
                    isImporting.toggle()
                } label: {
                    Label("Send Payload", systemImage: "shippingbox.circle")
                }
            }
        }).fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: InputDoument.readableContentTypes,
            allowsMultipleSelection: true,
            onCompletion: { res in
                Task(priority: .background) {
                    if let selectedFile = try? res.get().first {
                        if selectedFile.pathExtension == "bin" {
                            if selectedFile.startAccessingSecurityScopedResource() {
                                do {
                                    let data = try Data(contentsOf: selectedFile)
                                    let uploaded = await Goldhen.uploadData(data: data)
                                    selectedFile.stopAccessingSecurityScopedResource()
                                } catch {
                                    print("Could not send \(error)")
                                }
                                selectedFile.stopAccessingSecurityScopedResource()
                            } else {
                                // Handle denied access
                                print("Access denied")
                            }
                        } else {
                            print("not a bin")
                        }
                    }
                }
            }
        )
    }
}

struct ConsoleListItem_Previews: PreviewProvider {
    
    
    static var previews: some View {
        VStack {
            ConsoleListItem(console: fakeConsoles[0])
                .environmentObject(SyncServiceImpl.test())
            ConsoleListItem(console: fakeConsoles[1])
                .environmentObject(SyncServiceImpl.test())
            Spacer()
        }
        VStack {
            ConsoleListItem(console: fakeConsoles[0])
                .environmentObject(SyncServiceImpl.test()).colorScheme(.dark)
            ConsoleListItem(console: fakeConsoles[1])
                .environmentObject(SyncServiceImpl.test()).colorScheme(.dark)
            
        Spacer()
        }.colorScheme(.dark)
    }
}
