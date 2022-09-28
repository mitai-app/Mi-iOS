//
//  SmallCardView.swift
//  Mi
//
//  Created by Vonley on 9/24/22.
//

import SwiftUI

struct SmallCardView: View {
    var item: Console = fakeConsoles[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "gear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 99)
                .padding(.vertical)
            Text(item.name)
                .font(.headline)
                .fontWeight(.bold)
            Text(item.ip)
                .opacity(0.7)
        }.padding(.all)
            .foregroundColor(.white)
            .frame(height: 222)
            .background(grads[1])
            .cornerRadius(30)
    }
}

struct SmallCardView_Previews: PreviewProvider {
    static var previews: some View {
        SmallCardView()
    }
}
