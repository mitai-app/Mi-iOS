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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if (item.type == .ps3()) {
                KFImage(URL(string: Webman.buildScreenshotURL(ip: item.ip)))
                    .placeholder {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    }
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
                Text(item.name)
                    .font(.title2)
                .fontWeight(.bold)
                Text(item.ip)
                    .opacity(0.7)
            }.frame(maxWidth: .infinity, alignment:.leading).padding(.all).background(Color("tabcolor").opacity(0.3))
        }.foregroundColor(.white)
            .background(Color("tabcolor")).cornerRadius(30)
    }
}


struct ConsoleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleHeaderView(item: fakeConsoles[0])
        ConsoleHeaderView(item: fakeConsoles[0]).colorScheme(.dark)
    }
}
