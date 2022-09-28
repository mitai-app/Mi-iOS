//
//  ConsoleListItem.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI

struct ConsoleListItem: View {
    var console: Console = fakeConsoles[0]
    var body: some View {
        HStack {
            var image = "gear"
            
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36, alignment: .center)
                .background(grads[0])
                .foregroundColor(.white)
                .mask(Circle())
                .onAppear {
                    switch (console.type) {
                        case .ps3(_):
                            image = "gear"
                            break
                        case .ps4(_):
                            image = "gear"
                            break
                        case .unknown(_):
                            image = "gear"
                            break
                    }
                }
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

struct ConsoleListItem_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleListItem()
    }
}
