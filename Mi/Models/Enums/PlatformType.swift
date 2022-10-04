//
//  PlatformType.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation

enum PlatformType: CaseIterable, Equatable {
    static var allCases: [PlatformType] {
        return [unknown(), ps3(), ps4()]
    }
    
    
    case unknown(features: [Feature] = [Feature.ftp()])
    case ps3(features: [Feature] = [
            Feature.ps3mapi(),
            Feature.webman(),
            Feature.ccapi()
        ]
    )
    case ps4(features: [Feature] = [
            Feature.goldhen(),
            Feature.netcat(),
            Feature.orbisapi(),
            Feature.rpi(),
            Feature.klog()
        ]
    )
    
    var title: String {
        switch(self) {
        case .unknown(_):
            return "Unknown"
        case .ps4(_):
            return "PS4"
        case .ps3(_):
            return "PS3"
        }
    }
}
