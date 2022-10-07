//
//  ListItem.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import FilesProvider

struct ListItem: View {
    
    @State var file: FTPFile!
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "house")
                .renderingMode(.original)
                .frame(width: 36, height: 36)
                .background(grads[1])
                .foregroundColor(Color.white)
                .mask(Circle())
            VStack(alignment: .leading, spacing: 4.0) {
                Text(file.name)
                
                Text(file.directory == true ? "Folder" : "File")
            }.padding()
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
    }
}
struct ListItem_Previews: PreviewProvider {
    
    static var previews: some View {
        ListItem(file: FTPFile(id: 1, directory: false, permissions: "", nbfiles: 1, owner: "ps4", group: "", size: 100, date: "June 4", name: "golhen.bin"))
    }
}

