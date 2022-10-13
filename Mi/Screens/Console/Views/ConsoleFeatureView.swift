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
    @EnvironmentObject var sync: SyncServiceImpl
    @State var consoleInfo: ConsoleInfo? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if item.isPs3 {
                    ConsoleHeaderView(item: item, consoleInfo: $consoleInfo)
                    WMControlView(console: item, vm: WMControlViewModel(console: item))
                    PS3MControlView(console: item, consoleInfo: $consoleInfo, vm: PS3MControlViewModel(console: item))
                    WMGameView(console: item)
                } else if item.isPs4 {
                    GoldhenBinView(vm: GoldhenBinViewModel(console: item))
                }
            }
            .onAppear {
                print("Current Target: \(sync.target?.ip ?? "no target")")
            }
        }
    }
}

struct ConsoleFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleFeatureView(item: fakeConsoles[1],
                           consoleInfo:
                            ConsoleInfo(
                                firmware: "9.00",
                                type: ConsoleType.DEX,
                                temp: Temperature(
                                    cpu: "50",
                                    rsx: "50")
                            )
                        ).environmentObject(SyncServiceImpl.test())
        ConsoleFeatureView(item: fakeConsoles[0]).environmentObject(SyncServiceImpl.test())
    }
}

