//
//  TabBarItem.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import Foundation
import SwiftUI

/*
struct TabBarItem: Hashable {
    let iconName: String
    let title: String
    let color: Color
}*/


enum TabBarItem: Hashable {
    case home, package, settings
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .package: return "icloud"
        case .settings: return "gear"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .package: return "Package"
        case .settings: return "Settings"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.red
        case .package: return Color.blue
        case .settings: return Color.green
        }
    }
    
    
    
}
