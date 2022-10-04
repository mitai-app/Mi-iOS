//
//  ConsoleSectionView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI

struct ConsoleSectionView: View {
    
    @StateObject var sync: SyncService
    @State var show: Bool = false
    
    var body: some View {
        ScrollView(.vertical) {
            Text("Consoles")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            VStack {
                ForEach($sync.active) { item in
                    ConsoleListItem(console: item.wrappedValue)
                    .onTapGesture {
                        print("Setting Console: \(item.ip)")
                        sync.target = item.wrappedValue
                        show.toggle()
                    }
                    
                }
            }.sheet(isPresented: $show, content: {
                ConsoleFeatureView(item: sync.target!)
            })
        }.refreshable {
            sync.findDevices { consoles in
                    
            }
        }
    }
}

struct ConsoleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleSectionView(sync: SyncService.test())
    }
}
