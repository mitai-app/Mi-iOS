//
//  ListView.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct ListView: View {
    
    @State var show = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0 ..< 5) { item in
                    ListItem()
                        .sheet(isPresented: $show, content: {
                            ConsoleFeatureView()
                        }).onTapGesture {
                            show.toggle()
                        }
                }
            }
            .navigationTitle("Consoles")
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}


