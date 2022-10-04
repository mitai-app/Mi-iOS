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
    @EnvironmentObject var sync: SyncService
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                if item.type == .ps3() {
                    
                    ConsoleHeaderView(item: item)
                    WMControlView(console: item, vm: WMControlViewModel(console: item))
                    PS3MControlView(console: item, vm: PS3MControlViewModel(console: item))
                    WMGameView(console: item)
                } else {
                    GoldhenBinView(vm: GoldhenBinViewModel(console: item))
                }
            }.onAppear {
                sync.target = item
                print("Current Target: \(sync.target?.ip ?? "no target")")
            }
        }.foregroundColor(.white)
            .background(Color("quinary"))
    }
}

struct ConsoleFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleFeatureView(item: fakeConsoles[1]).environmentObject(SyncService.test())
    }
}

