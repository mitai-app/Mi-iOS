//
//  Data.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import SwiftUI
import CoreData

struct Console: Identifiable {
    var id: String = ""
    var ip: String
    var name: String
    var wifi: String = ""
    var lastKnownReachable: Bool = true
    var type: PlatformType = .unknown
    var features: [Feature] = []
    var pinned: Bool = false
}

extension ConsoleEntity {
    
    
    func fromConsoleEntity() -> Console {
        let decoder = JSONDecoder()
        var features: [Feature] = []
        if let data = self.features {
            if let feat = try? decoder.decode([Feature].self, from: data) {
                features = feat
            }
        }
        let id = self.id!
        let ip = self.ip!
        let name = self.name!
        let wifi = self.wifi!
        let lastKnownReachable = self.lastKnownReachable
        let type = PlatformType(rawValue: self.type) ?? PlatformType.unknown
        let pinned = self.pinned
        return Console(id: id, ip: ip, name: name, wifi: wifi, lastKnownReachable: lastKnownReachable, type: type, features: features, pinned: pinned)
    }
}


extension Console {
    var isPs4: Bool {
        return type == .ps4
    }
    
    var isPs3: Bool {
        return type == .ps3
    }
    
    func toConsoleEntity(moc: NSManagedObjectContext) -> ConsoleEntity {
        let encoder = JSONEncoder()
        let entity = ConsoleEntity(context: moc)
        entity.id = self.id
        entity.ip = self.ip
        entity.name = self.name
        entity.wifi = self.wifi
        entity.lastKnownReachable = self.lastKnownReachable
        entity.type = self.type.rawValue
        entity.features = try? encoder.encode(self.features)
        entity.pinned = self.pinned
        return entity
    }
    
}

enum ConsoleType: String {
    case UNK = "Unknown", CEX = "CEX", DEX = "DEX", DEX_COBRA = "DEX COBRA", TOOL = "TOOL"
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
