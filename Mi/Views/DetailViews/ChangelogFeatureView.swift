//
//  ChangelogFeatureView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ChangelogFeatureView: View {
    
    var item: Changelog = fakeChangeLogs[0]
    
    var body: some View {
        ScrollView {
            HeaderView(item: item)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(item.version)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on.")
                
                ForEach(0 ..< 2) { item in
                    Text("SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on.")
                }
            }.padding()
        }
    }
}

struct ChangelogFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogFeatureView()
    }
}

struct HeaderView: View {
    var item: Changelog = fakeChangeLogs[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("karl_marx")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 128)
            Text(item.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(item.summary)
                .opacity(0.7)
        }.padding(.all)
            .foregroundColor(.white)
            .background(grads[0])
    }
}
