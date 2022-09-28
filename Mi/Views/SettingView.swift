//
//  SettingView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct SettingView: View {
    @State var jbService = false
    
    var body: some View {
        List {
            Toggle(isOn: $jbService) {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "karl_marx")
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
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
