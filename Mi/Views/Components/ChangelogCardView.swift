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
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "gear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 128)
                .padding(.vertical)
            Text(item.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(item.summary)
                .opacity(0.7)
        }.padding(.all)
            .foregroundColor(.white)
            .frame(width: 252, height: 270)
            .background(grads[2]).cornerRadius(30)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogCardView()
    }
}
