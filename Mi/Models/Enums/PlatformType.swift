//
//  PlatformType.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation

enum PlatformType: Int16 {
  
    case unknown = 0, ps3, ps4, ps5
    
}


extension PlatformType: CaseIterable, Equatable {
   
    static var allCases: [PlatformType] {
        return [.unknown, .ps3, .ps4, .ps5]
    }
    
    
    var title: String {
        switch(self) {
        case .unknown:
            return "Unknown"
        case .ps5:
            return "PS4"
        case .ps4:
            return "PS4"
        case .ps3:
            return "PS3"
        }
    }
    
    var features: [Feature] {
        return PlatformType.getFeature(platform: self)
    }
    
    static func getFeature(platform: PlatformType) -> [Feature] {
        switch platform {
            
        case .unknown:
            return [
                Feature.ftp
            ]
        case .ps3:
            return [
                    Feature.ps3mapi,
                    Feature.webman,
                    Feature.ccapi
                ]
        case .ps4:
            return [
                Feature.goldhen,
                Feature.netcat,
                Feature.orbisapi,
                Feature.rpi,
                Feature.klog
            ]
        case .ps5:
            return [
                Feature.klog
            ]
        }
    }
    
}
