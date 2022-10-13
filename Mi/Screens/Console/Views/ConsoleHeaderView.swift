//
//  ConsoleHeaderView.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import SwiftUI
import Kingfisher

struct ConsoleHeaderView: View {
    var item: Console
    @Binding var consoleInfo: ConsoleInfo?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if (consoleInfo != nil) {
                if (item.type == .ps3) {
                    KFImage(URL(string: Webman.buildScreenshotURL(ip: item.ip)))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } else {
                    Image("play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }
                VStack(alignment: .leading) {
                    Text("FW: \(consoleInfo?.firmware ?? "Unknown FW")")
                        .font(.title2)
                    .fontWeight(.bold)
                    Text("Type: \(consoleInfo?.type.rawValue ?? "Unknown FW") - \(consoleInfo?.temp.format(farenheit: false) ?? "")")
                        .opacity(0.7)
                }.frame(maxWidth: .infinity, alignment:.leading)
                    .padding(.all)
                    .background(Color("tabcolor").opacity(0.3))
            }
        }.foregroundColor(.white)
    }
}


struct ConsoleHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        ConsoleHeaderView(item: fakeConsoles[1], consoleInfo: .constant(ConsoleInfo(firmware: "9.00", type: ConsoleType.DEX, temp: Temperature(cpu: "50", rsx: "50"))))
        ConsoleHeaderView(item: fakeConsoles[1], consoleInfo: .constant(ConsoleInfo(firmware: "9.00", type: ConsoleType.DEX, temp: Temperature(cpu: "50", rsx: "50")))).colorScheme(.dark)
    }
}
