//
//  SettingView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct SettingView: View {
    
    @State var jbService = true
    
    @EnvironmentObject var sync: SyncServiceImpl
    @EnvironmentObject var mi: MiServerImpl
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $jbService) {
                    HStack(alignment: .center, spacing: 20) {
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        VStack(alignment: .leading) {
                            if(jbService) {
                                Text("PS4 Mi Host Running...")
                            } else {
                                Text("PS4 Mi Host Stopped...")
                            }
                        }
                    }.padding(8)
                }.onChange(of: jbService) { newValue in
                    print("Value: \(newValue)")
                    if newValue {
                        mi.start()
                    } else {
                        mi.stop()
                    }
                }
            }.padding()
        }
        .customNavigationTitle("Settings")
        .customNavigationBarBackButtonHidden(true)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(SyncServiceImpl.test())
            .environmentObject(MiServerImpl())
    }
}
