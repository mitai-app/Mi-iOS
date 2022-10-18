//
//  PackageViewItem.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import SwiftUI
import Kingfisher

struct PackageViewItem: View {
    var package: PackageModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                KFImage(URL(string: package.icon))
                    .placeholder {
                            Image(systemName: "paperplane.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .frame(maxWidth: 50)
                                .padding()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .frame(maxWidth: 50)
                    .padding()
                    
                VStack(alignment: .leading, spacing: 8) {
                    if #available(iOS 15.0, *) {
                        Text("\(package.name) \(package.type.rawValue) by \(package.author)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .dynamicTypeSize(DynamicTypeSize.small)
                            .foregroundColor(Color("navcolor"))
                    } else {
                        // Fallback on earlier versions
                        Text("\(package.name) \(package.type.rawValue) by \(package.author)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("navcolor"))
                        .sizeCategory(.small)
                    }
                        
                    if #available(iOS 15.0, *) {
                        Text("ver: \(package.version)")
                            .foregroundColor(.gray)
                            .dynamicTypeSize(DynamicTypeSize.small)
                    } else {
                        // Fallback on earlier versions
                        Text("ver: \(package.version)")
                            .foregroundColor(.gray)
                            .sizeCategory(.small)
                    }
                }
                Spacer()
            }
        }
    }
}

struct PackageViewItem_Previews: PreviewProvider {
    static var previews: some View {
        PackageViewItem(package: PackageModel(
            name: "GoldHen",
            author: "SiStRo",
            version: "2.2.4",
            type: PackageType.plugin,
            icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
            link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
            dl: [:]))
    }
}
