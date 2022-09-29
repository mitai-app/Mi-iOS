//
//  ConsoleFeatureView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
import MapKit
import Kingfisher

struct ConsoleFeatureView: View {
    
    @State var item: Console
    
    var body: some View {
        ScrollView {
            ConsoleHeaderView(item: item)
            
            VStack(alignment: .leading, spacing: 20) {
                if item.type == .ps3() {
                    WMControlView(console: item, vm: WMControlViewModel(console: item))
                    PS3MControlView(console: item, vm: PS3MControlViewModel(console: item))
                    WMGameView(console: item)
                } else {
                    GoldhenBinView(vm: GoldhenBinViewModel(console: item))
                }
            }.onAppear {
                SyncService.shared.target = item
                print("Current Target \(SyncService.shared.target)")
            }
        }.foregroundColor(.black)
    }
}

struct ConsoleFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleFeatureView(item: fakeConsoles[0])
    }
}

