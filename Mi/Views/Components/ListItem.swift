//
//  ListItem.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ListItem: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "house")
                .renderingMode(.original)
                .frame(width: 36, height: 36)
                .background(grads[1])
                .foregroundColor(Color.white)
                .mask(Circle())
            VStack(alignment: .leading, spacing: 4.0) {
                Text("Intro to iOS Design")
                
                Text("Design an iOS app from scratch for iOS 15, iPadOS and Big Sur.")
            }.padding()
        }
        .padding(.horizontal)
    }
}
struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem()
    }
}
