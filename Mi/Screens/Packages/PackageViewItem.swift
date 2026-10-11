//
//  PackageViewItem.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import SwiftUI
import UIKit
import Kingfisher

/// A single package row: app-style icon, name, and a `type · author · version`
/// subtitle. The install control is supplied by the enclosing list so this view
/// stays presentation-only.
struct PackageViewItem: View {
    let package: PackageModel

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: package.icon))
                .placeholder { placeholder }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 3) {
                Text(package.name)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(package.type.rawValue) · \(package.author) · v\(package.version)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 11)
            .fill(Color(.systemGray5))
            .frame(width: 46, height: 46)
            .overlay(
                Image(systemName: package.type.symbol)
                    .foregroundColor(.secondary)
            )
    }
}

extension PackageType {
    /// SF Symbol used as the fallback icon for a package of this type.
    var symbol: String {
        switch self {
        case .plugin: return "puzzlepiece.extension.fill"
        case .tool: return "wrench.and.screwdriver.fill"
        case .app: return "app.fill"
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
        .padding()
    }
}
