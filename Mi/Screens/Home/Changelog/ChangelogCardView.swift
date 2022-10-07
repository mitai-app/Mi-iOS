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
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "info")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .padding(.horizontal)
                if let change = item {
                    VStack(alignment: .leading) {
                        
                        Text(change.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(alignment: .leading)
                        Text("New changes added")
                            .opacity(0.7)
                            .frame(alignment: .leading)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }.frame(height: 80)
        .frame(maxWidth: .infinity)
        .cornerRadius(16)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogCardView(item: fakeChangeLogs[0].changelogs[0])
    }
}
