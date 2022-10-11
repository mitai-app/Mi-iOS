//
//  ConsoleSectionView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI

struct ConsoleSectionView: View {
    
    @EnvironmentObject var sync: SyncServiceImpl
    @State var show: Bool = false
    @State var consoles: Bool = false
    var body: some View {
        VStack {
            HStack {
                if sync.active.count > 0 {
                    Text("Found")
                        .font(.title).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    Text("Searching...")
                        .font(.title).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                Button(action: {
                    alertMessage(
                        title: "Add",
                        message: "Add a new console via ip",
                        placeholder: "console ip",
                        onConfirm: { string in
                            SyncServiceImpl.shared.active.append(Console(
                                ip: string,
                                name: string,
                                wifi: "",
                                lastKnownReachable: true, type: PlatformType.unknown(features: []),
                                features: [],
                                pinned: false))
                        }) {
                            // do nothing
                        }
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }).padding().foregroundColor(Color("navcolor"))
            }
            ScrollView(.vertical) {
                ForEach($sync.active) { item in
                    ConsoleListItem(console: item.wrappedValue)
                    
                }
            }
        }.refreshable {
            sync.findDevices { consoles in
                    
            }
        }
    }
}

struct ConsoleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleSectionView()
            .environmentObject(SyncServiceImpl.test())
    }
}
