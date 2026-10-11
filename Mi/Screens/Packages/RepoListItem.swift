//
//  RepoListItem.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import SwiftUI
import UIKit

/// A repository shown as a compact, collapsible section: an icon, the repo name,
/// a `N packages · author` subtitle, and a disclosure chevron. Tapping the header
/// expands an inline list of its packages.
struct RepoListItem: View {
    let response: PackageResponse

    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    icon
                    VStack(alignment: .leading, spacing: 2) {
                        Text(response.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text("\(response.packages.count) \(response.packages.count == 1 ? "package" : "packages") · \(response.author)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                Divider()
                PackageListView(packages: response.packages)
                    .padding(.vertical, 4)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var icon: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color("navcolor").opacity(0.12))
            .frame(width: 42, height: 42)
            .overlay(
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("navcolor"))
            )
    }
}

struct RepoListItem_Previews: PreviewProvider {
    static var previews: some View {
        let response = PackageResponse(title: "Common PS4 payloads", author: "mitai", banner: "Banner", description: "Description", packages: [PackageModel(
            name: "GoldHen",
            author: "SiStRo",
            version: "2.2.4",
            type: PackageType.plugin,
            icon: "https://avatars.githubusercontent.com/u/91367123?s=50&v=4",
            link: "https://github.com/GoldHEN/GoldHEN/blob/19d768eef604b5df16f4be87755c9877c70a0b55/goldhen_2.2.4_900.bin?raw=true",
            dl: [:])])
        RepoListItem(response: response)
            .environmentObject(SyncServiceImpl.test())
            .padding()
    }
}
