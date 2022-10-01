//
//  ListItem.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import FilesProvider

struct ListItem: View {
    
    @State var file: FileObject? = FileObject(allValues: [:])
    
    var body: some View {
        if let fo = file {
        HStack(alignment: .center) {
            Image(systemName: "house")
                .renderingMode(.original)
                .frame(width: 36, height: 36)
                .background(grads[1])
                .foregroundColor(Color.white)
                .mask(Circle())
            VStack(alignment: .leading, spacing: 4.0) {
                Text(fo.name)
                
                Text(fo.isDirectory == true ? "Folder" : "File")
            }.padding()
        }
        .padding(.horizontal)
        } else {
            HStack(alignment: .center) {
                Image(systemName: "house")
                    .renderingMode(.original)
                    .frame(width: 36, height: 36)
                    .background(grads[1])
                    .foregroundColor(Color.white)
                    .mask(Circle())
                VStack(alignment: .leading, spacing: 4.0) {
                    Text("file-name.mi")
                    
                    Text("Folder")
                }.padding()
            }
            .padding(.horizontal)
        }
    }
}
struct ListItem_Previews: PreviewProvider {
    
    static var previews: some View {
        ListItem()
    }
}
