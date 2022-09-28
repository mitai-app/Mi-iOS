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
