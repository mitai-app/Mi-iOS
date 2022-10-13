//
//  Feature.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation

/**
 * We wont scan for netcat, this port will be ignored since its a
 * oneshot jb exploit. Our MiJbServer class will handle the netcat
 * payload
 */
enum Feature: Int16, CaseIterable, Codable {
    
    static var allCases: [Feature] {
        return [.none, .netcat, .goldhen, .orbisapi, .rpi, .ps3mapi, .webman, .klog, .ftp]
    }
    
    case none = 0, netcat, goldhen,orbisapi,rpi,ps3mapi,ccapi, webman,klog, ftp
    
}

extension Array where Element == Feature {
    func commaSeperated() -> String {
        return map { $0.title }.joined(separator: ", ").uppercased()
    }
}

extension Feature: Hashable {
    
    var title: String {
        switch self {
            
        case .none:
            return ""
        case .netcat:
            return "Netcat"
        case .goldhen:
            return "GoldHen"
        case .orbisapi:
            return "OrbisApi"
        case .rpi:
            return "Remote Package Installer"
        case .ps3mapi:
            return "PS3mapi"
        case .ccapi:
            return "CCAPI"
        case .webman:
            return "WebMan"
        case .klog:
            return "KLog"
        case .ftp:
            return "FTP"
        }
    }
    
    func find(id: Int) -> Feature? {
        return Feature.allCases[id]
    }
    
    var ports: [Int] {
        return Feature.getPort(feat: self)
    }
    
    var prtcl: Protocols {
        return Feature.getType(feat: self)
    }


    static func getPort(feat: Feature) -> [Int] {
        switch feat {
        case .none:
            return []
        case .netcat:
            return Array(arrayLiteral: 9021, 9020)
        case .goldhen:
            return Array(arrayLiteral: 9090)
        case .orbisapi:
            return Array(arrayLiteral: 6023)
        case .rpi:
            return Array(arrayLiteral: 12800)
        case .ps3mapi:
            return Array(arrayLiteral: 7887)
        case .ccapi:
            return Array(arrayLiteral: 6333)
        case .webman:
            return Array(arrayLiteral: 80)
        case .klog:
            return Array(arrayLiteral: 3232)
        case .ftp:
            return Array(arrayLiteral: 21, 2121)
        }
    }
    
    static func getType(feat: Feature) -> Protocols {
        switch feat {
        case .none:
            return Protocols.none
        case .netcat:
            return Protocols.socket
        case .goldhen:
            return Protocols.socket
        case .orbisapi:
            return Protocols.socket
        case .rpi:
            return Protocols.http
        case .ps3mapi:
            return Protocols.socket
        case .ccapi:
            return Protocols.http
        case .webman:
            return Protocols.http
        case .klog:
            return Protocols.socket
        case .ftp:
            return Protocols.ftp
        }
    }
    
        /**
         * These fields are for client
         * Due to GoldenHen & NetCat being the payload sender,
         * we want to be extract careful what we send there.
         * Goldenhen Bin Uploader stops working after a while
         * NetCat
         */
        //arrayOf(ORBISAPI, RPI, PS3MAPI, CCAPI, WEBMAN, FTP, KLOG)
    static var stableFeatures: [Feature]  {
        return Feature.allCases.filter { feature in
            switch(feature) {
            case .none:
                    return false
            case .netcat:
                    return false
            case .goldhen:
                    return true
            case .orbisapi:
                    return true
            case .rpi:
                    return true
            case .ps3mapi:
                    return true
            case .ccapi:
                    return true
            case .webman:
                    return true
            case .klog:
                    return true
            case .ftp:
                    return true
            }
        }
    }

        /**
         * These are stable sockets that are allowed to be opened for however long
         */
        static var allowedToOpen: [Feature]  {
            return Feature.allCases.filter { feature in
                switch(feature) {
                case .none:
                        return false
                case .netcat:
                        return false
                case .goldhen:
                        return false
                case .orbisapi:
                        return true
                case .rpi:
                        return false
                case .ps3mapi:
                        return true
                case .ccapi:
                        return true
                case .webman:
                        return true
                case .klog:
                        return true
                case .ftp:
                        return false
                }
            }
        }
            
        static func validateResponse(s: String) -> Bool {
            return s.lowercased().contains("ps3mapi") || s.lowercased()
                .contains("webman") || s.lowercased().contains("dex") || s.lowercased().contains("d-rex") || s.lowercased()
                .contains("cex") || s.lowercased()
                .contains("rebug") ||
                s.lowercased().contains("rsx")
            }
            //also validated ccapi, webman, ps3mapi, goldhen, orbisapi
}
