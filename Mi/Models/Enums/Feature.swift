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
enum Feature: CaseIterable {
    static var allCases: [Feature] {
        return [.none(), .netcat(), .goldhen(), .orbisapi(), .rpi(), .ps3mapi(), .webman(), .klog(), .ftp()]
    }
    
    
    case none(protocoll: Protocols = Protocols.none, port: Array<Int> = Array(arrayLiteral: 0))
    case netcat(protocoll: Protocols = Protocols.socket, port: Array<Int> = Array(arrayLiteral: 9021, 9020))
    case goldhen(protocoll: Protocols = Protocols.socket, port: Array<Int> = Array(arrayLiteral: 9090))
    case orbisapi(protocoll: Protocols = Protocols.socket, port: Array<Int> = Array(arrayLiteral: 6023))
    case rpi(protocoll: Protocols = Protocols.http, port: Array<Int> = Array(arrayLiteral: 12800))
    case ps3mapi(protocoll: Protocols = Protocols.socket, port: Array<Int> = Array(arrayLiteral: 7887))
    case ccapi(protocoll: Protocols = Protocols.http, port: Array<Int> = Array(arrayLiteral: 6333))
    case webman(protocoll: Protocols = Protocols.http, port: Array<Int> = Array(arrayLiteral: 80))
    case klog(protocoll: Protocols = Protocols.socket, port: Array<Int> = Array(arrayLiteral: 3232))
    case ftp(protocoll: Protocols = Protocols.ftp, port: Array<Int> = Array(arrayLiteral: 21, 2121))

   
}

extension Feature: Hashable {
    
    func find(id: Int) -> Feature? {
        return Feature.allCases[id]
    }

    static func getPort(feat: Feature) -> [Int] {
        switch feat {
            
        case .none(protocoll: _, port: let port):
            return port
        case .netcat(protocoll: _, port: let port):
            return port
        case .goldhen(protocoll: _, port: let port):
            return port
        case .orbisapi(protocoll: _, port: let port):
            return port
        case .rpi(protocoll: _, port: let port):
            return port
        case .ps3mapi(protocoll: _, port: let port):
            return port
        case .ccapi(protocoll: _, port: let port):
            return port
        case .webman(protocoll: _, port: let port):
            return port
        case .klog(protocoll: _, port: let port):
            return port
        case .ftp(protocoll: _, port: let port):
            return port
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
            case .none(_, _):
                    return false
            case .netcat(_, _):
                    return false
            case .goldhen(_, _):
                    return true
            case .orbisapi(protocoll: _, port: _):
                    return true
            case .rpi(protocoll: _, port: _):
                    return true
            case .ps3mapi(protocoll: _, port: _):
                    return true
            case .ccapi(protocoll: _, port: _):
                    return true
            case .webman(protocoll: _, port: _):
                    return true
            case .klog(protocoll: _, port: _):
                    return true
            case .ftp(protocoll: _, port: _):
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
                case .none(_, _):
                        return false
                case .netcat(_, _):
                        return false
                case .goldhen(_, _):
                        return false
                case .orbisapi(protocoll: _, port: _):
                        return true
                case .rpi(protocoll: _, port: _):
                        return false
                case .ps3mapi(protocoll: _, port: _):
                        return true
                case .ccapi(protocoll: _, port: _):
                        return true
                case .webman(protocoll: _, port: _):
                        return true
                case .klog(protocoll: _, port: _):
                        return true
                case .ftp(protocoll: _, port: _):
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
