//
//  ConsoleFeatureView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
import MapKit
import Kingfisher

struct ConsoleFeatureView: View {
    
    var item: Console = fakeConsoles[0]
    
    var body: some View {
        ScrollView {
            ConsoleHeaderView(item: item)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(item.name)
                    .font(.title)
                    .fontWeight(.bold).padding()
                
                Text("SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on. SwiftUI is hands on.").padding()
                
                WMControlView(console: item, vm: WMControlViewModel(console: item))
                WMGameView(console: item)
                
            }
        }
    }
}

struct ConsoleFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleFeatureView()
    }
}

struct ConsoleHeaderView: View {
    var item: Console = fakeConsoles[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("karl_marx")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 128)
            Text(item.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(item.ip)
                .opacity(0.7)
        }.padding(.all)
            .foregroundColor(.white)
            .background(grads[0])
    }
}
