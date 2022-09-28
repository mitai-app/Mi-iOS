//
//  ConsoleSectionView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI

struct ConsoleSectionView: View {
    
    @StateObject var sync: SyncService
    
    var body: some View {
        ScrollView(.vertical) {
            Text("Consoles")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ForEach(sync.active) { item in
                NavigationLink(destination: ConsoleFeatureView(item: item)) {
                    ConsoleListItem(console: item)
                }
            }
        }
    }
}

struct ConsoleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleSectionView(sync: SyncService.test())
    }
}
