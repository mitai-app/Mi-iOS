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
