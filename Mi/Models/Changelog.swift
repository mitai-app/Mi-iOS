//
//  Changelog.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import Foundation
import SwiftUI

struct Changelog: Decodable, Hashable, Identifiable {
    var id: String {
        return name
    }
    
    
    static func == (lhs: Changelog, rhs: Changelog) -> Bool {
        return lhs.name == rhs.name
    }
    
    let name: String
    let author: String
    let version: String
    let contributors: [String]
    let changelog: [String]
    let build: String
    let changelogs: [Changes]
    let thanks: [String]
    var gradient: LinearGradient {
        return grads[Int.random(in: 0..<grads.count)]
    }
    
}

struct Changes: Decodable, Hashable, Identifiable {
    var id: String {
        return name
    }
    
    static func == (lhs: Changes, rhs: Changes) -> Bool {
        return lhs.name == rhs.name
    }
    
    let name: String
    let changes: [String]
    let build: String
}


