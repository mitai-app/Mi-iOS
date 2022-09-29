//
//  CardView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ChangelogCardView: View {
    var item: Changelog = fakeChangeLogs[0]
    
    var body: some View {
        
        HStack(alignment: .center) {
            Image(systemName: "gear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading) {
                
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(item.summary)
                    .opacity(0.7)
            }
            
        }.frame(width: 300, height: 80)
            .background(grads[1])
            .cornerRadius(16)
            .foregroundColor(.white)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogCardView()
    }
}
