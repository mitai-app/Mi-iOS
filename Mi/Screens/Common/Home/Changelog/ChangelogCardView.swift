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
            Image(systemName: "info")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            if let change = item {
                VStack(alignment: .leading) {
                    
                    Text(change.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("New changes added")
                        .opacity(0.7)
                }
            }
            
        }.frame(height: 80)
            .frame(maxWidth: .infinity)
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
