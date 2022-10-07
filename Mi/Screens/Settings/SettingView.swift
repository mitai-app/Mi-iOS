//
//  SettingView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct SettingView: View {
    
    @State var jbService = false
    
    @EnvironmentObject var sync: SyncServiceImpl
    
    var body: some View {
        CustomNavView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $jbService) {
                        HStack(alignment: .center, spacing: 20) {
                            Image(systemName: "house")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            VStack(alignment: .leading) {
                                if(jbService) {
                                    Text("Disable JB Service")
                                } else {
                                    Text("Enable JB Service")
                                }
                            }
                        }.padding(8)
                    }
                }.padding()
            }
            .customNavigationTitle("Settings")
            .customNavigationBarBackButtonHidden(true)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView().environmentObject(SyncServiceImpl.test())
    }
}
