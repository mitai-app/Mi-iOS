//
//  ListItem.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import FilesProvider

struct ListItem: View {
    
    @Binding var file: FTPFile
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: file.directory ? "folder" : "doc")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .foregroundColor(file.directory ? Color("navcolor") : Color("foreground"))
                .accentColor(.white)
            VStack(alignment: .leading, spacing: 2.0) {
                Text(file.name)
                    .font(SwiftUI.Font.title3)
                    .fontWeight(.bold)
                    .foregroundColor(file.directory ? Color("navcolor") : Color("foreground"))
                
                Text(file.date)
                    .foregroundColor(.gray)
            }.padding(.horizontal)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
    }
}
struct ListItem_Previews: PreviewProvider {
    
    
    static var previews: some View {
        ListItem(file: .constant(
            FTPFile(cwd: "/", directory: false, permissions: "", nbfiles: 1, owner: "ps4", group: "", size: 100, date: "June 4", name: "goldhen.bin")
        ))
        ListItem(file: .constant(
            FTPFile(cwd: "/", directory: false, permissions: "", nbfiles: 1, owner: "ps4", group: "", size: 100, date: "June 4", name: "goldhen.bin")
        )).preferredColorScheme(.dark)
    }
}

