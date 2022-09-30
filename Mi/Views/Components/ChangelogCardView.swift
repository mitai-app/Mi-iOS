//
//  CardView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ChangelogCardView: View {
    @State var item: Changes
    
    var body: some View {
        
        HStack(alignment: .center) {
            Image(systemName: "gear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
            if let change = item {
                VStack(alignment: .leading) {
                    
                    Text(change.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(change.build)
                        .opacity(0.7)
                }
            }
            
        }.frame(width: 300, height: 80)
            .background(grads[1])
            .cornerRadius(16)
            .foregroundColor(.white)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogCardView(item: fakeChangeLogs[0].changelogs[0])
    }
}
