//
//  ChangelogFeatureView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ChangelogFeatureView: View {
    
    var changelog: Changelog
    var item: Changes
    
    var body: some View {
        ScrollView {
            HeaderView(item: item)
            
            if let change = item {
                VStack(alignment: .leading, spacing: 20) {
                    Text(change.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    ForEach(0..<change.changes.count) { id in
                        Text(change.changes[id])
                    }
                    Text(change.build)
                
                }.padding()
            }
        }
    }
}

struct ChangelogFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogFeatureView(changelog: fakeChangeLogs[0], item: Changes(name: "Hello", changes: [], build: "Welcome"))
    }
}

struct HeaderView: View {
    var item: Changes
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("red")
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading, spacing: 8) {
               
                Text(item.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(item.build)
                    .opacity(0.7)
            }.padding()
        }
            .foregroundColor(.white)
            .background(grads[1])
    }
}
