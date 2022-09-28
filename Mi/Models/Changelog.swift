//
//  Changelog.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import Foundation
import SwiftUI

struct Changelog: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let version: String
    let released: Date
    let gradient: LinearGradient = grads[Int.random(in: 0..<grads.count)]
}


