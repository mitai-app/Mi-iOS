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
    case home, consoles, package, ftp, settings
    
    var iconName: String {
        switch self {
            case .home: return "house"
            case .consoles: return "icloud"
            case .package: return "shippingbox"
            case .ftp: return "externaldrive.connected.to.line.below"
            case .settings: return "gear"
        }
    }
    
    var title: String {
        switch self {
            case .home: return "Home"
            case .consoles: return "Consoles"
            case .package: return "Packages"
            case .ftp: return "Ftp"
            case .settings: return "Settings"
        }
    }
    
    var color: Color {
        switch self {
            case .home: return Color.brown
            case .consoles: return Color.red
            case .package: return Color.blue
            case .ftp: return Color.orange
            case .settings: return Color.green
        }
    }
    
    
    
}
