//
//  LogView.swift
//  Mi
//
//  Created by Vonley on 10/10/22.
//

import SwiftUI

struct LogView: View {
    
    @Binding var logs: [MiResponse]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Logs")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .foregroundColor(Color("foreground"))
            if !logs.isEmpty {
                ForEach($logs) { log in
                    VStack(alignment: .leading) {
                        if let device = log.wrappedValue.device {
                            Text("\(device.device) (v\(device.version)): \(device.ip)")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .dynamicTypeSize(SwiftUI.DynamicTypeSize.small)
                            .frame(alignment:.leading)
                        }
                        Text("\(log.wrappedValue.response)")
                            .foregroundColor(Color.white)
                            .dynamicTypeSize(SwiftUI.DynamicTypeSize.xSmall)
                            .frame(alignment:.leading)
                            
                    }.padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(log.wrappedValue.data.cmd.bg)
                        .foregroundColor(Color("foreground"))
                        .cornerRadius(6)
                        .padding(.horizontal)
                        
                }
            } else if let localIp = SyncServiceImpl.shared.deviceIP {
                VStack(alignment: .leading) {
                    Text("Connect to: http://\(localIp):29999")
                    .foregroundColor(Color.white)
                    .fontWeight(.bold)
                    .dynamicTypeSize(SwiftUI.DynamicTypeSize.xSmall)
                }
                    .frame(alignment:.leading)
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("quaternary"))
                        .foregroundColor(Color("foreground"))
                        .cornerRadius(6)
                        .padding(.horizontal)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LogView_Previews: PreviewProvider {
    var o = [
        MiResponse(
            response: "Jailbreak complete", data: MiCmd(cmd: .success),
            device: Device(device: "Playstation 4", version: "9.00", ip: "192.168.11.246")
        ),
        MiResponse(
            response: "Jailbreak failed", data: MiCmd(cmd: .failed)
        ),
        MiResponse(
            response: "We're sending a payload in a bit", data: MiCmd(cmd: .pending)
        ),
        MiResponse(
            response: "We're sending a payload in a bit", data: MiCmd(cmd: .payload)
        )
    ]
    static var previews: some View {
        LogView(logs: .constant([]))
    }
}
