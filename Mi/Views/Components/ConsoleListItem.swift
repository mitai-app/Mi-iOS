//
//  ConsoleListItem.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI

struct ConsoleListItem: View {
    var console: Console
    
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    if console.type == .ps4() || console.type == .ps3() {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                            .foregroundColor(.white)
                        
                    } else {
                        Image(systemName: "network")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                            .foregroundColor(.white)
                    }
                }
                .padding(4)
                .background(grads[0])
                .mask(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(console.name)
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(console.ip)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.horizontal)
            }.padding(.horizontal)
        }
    }
}

struct ConsoleListItem_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleListItem(console: fakeConsoles[1])
    }
}
