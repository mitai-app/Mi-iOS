//
//  Data.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI

struct Console: Identifiable {
    var id = UUID()
    var ip: String
    var name: String
    var wifi: String = ""
    var lastKnownReachable: Bool = true
    var type: PlatformType = PlatformType.unknown()
    var features: [Feature] = []
    var pinned: Bool = false
}

enum ConsoleType {
    case UNK, CEX, DEX, DEX_COBRA, TOOL
}

extension ConsoleType {
    static func parse(type: String) -> ConsoleType {
        let t = type.lowercased().replacingOccurrences(of: "\r\n", with: "")
        switch t {
        case "cex":
            return ConsoleType.CEX
        case "dex":
            return ConsoleType.DEX
        case "dex cobra":
            return ConsoleType.DEX_COBRA
        case "tool":
            return ConsoleType.TOOL
        default:
            return ConsoleType.UNK
        }
    }
}
