//
//  SyncService.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation
import Alamofire
import Socket
import SwiftUI

class SyncService: ObservableObject {
    
    static let shared: SyncService = SyncService()
    
    static let psx = PSXServiceImpl()
    
    static func test() -> SyncService {
        let sync = SyncService()
        sync.active = fakeConsoles
        return sync
    }
    
    @Published var target: Console?
    @Published var active: [Console] = []
    
    private var map: [String:[Feature:Socket]] = [:]
    
    var ip: String? {
        return target?.ip
    }

    
    func getSocket(feat: Feature) -> Socket? {
        if let ip = self.ip {
            if map[ip] == nil {
                map[ip] = [:]
            }
            var socket = map[ip]?[feat]
            if socket == nil || socket?.isConnected == false || (socket?.isConnected == true && socket?.remoteConnectionClosed == true) {
                do {
                    let ports = Feature.getPort(feat: feat)
                    for port in ports {
                        socket = try Socket.create()
                        try socket?.connect(to: ip, port: Int32(port), timeout: 200)
                        map[ip]![feat] = socket
                        return socket
                    }
                } catch  {
                    print("Socket error \(error)")
                }
            }
            return socket
        }
        return nil
    }
    
    func getPotentialClients() -> [Console] {
        return active
    }
    
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    private func getAddress(for network: Network) -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        case ipv4 = "ipv4"
        case ipv6 = "ipv6"
    }
    
    
    private let log: Bool = false
       /**
        * Fetch All Connected Clients on the network
        * for potential match (IPV4 Clients Only)
        * TODO: Accommodate for IPV6 Clients
        */
    func findDevices(_ onCallback: (([Console]) -> Void)? = nil) {
        let localDeviceIp = getAddress(for: Network.wifi)!
        let last = localDeviceIp.lastIndex(of: ".")!
        let pre =  localDeviceIp.substring(to: last) + "." //localDeviceIp.substring(0, localDeviceIp.lastIndexOf(".") + 1)
        print("Constructed: \(pre)")
        Task {
            var consoles: [Console] = []
            for i in 0..<256 {
                let ip = "\(pre)\(i)"
                guard let console = await checkIp(ip: ip) else
                {
                    continue
                }
                consoles.append(console)
            }
            self.active = consoles
            await MainActor.run {
                if onCallback != nil {
                    onCallback!(self.active)
                }
            }
        }
    }
    
    private func checkIp(ip: String) async -> Console? {
        var console: Console =  Console(ip: ip, name: "Device")
        var name: String = ""
        var features: [Feature] = []
        var platform = PlatformType.unknown()
        for feat in Feature.allowedToOpen {
            var proto: Protocols
            var ports: [Int]
            switch(feat) {
            case .none(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .netcat(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .goldhen(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .orbisapi(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .rpi(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .ps3mapi(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .ccapi(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .webman(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .klog(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            case .ftp(protocoll: let protocoll, port: let port):
                proto =  protocoll
                ports = port
                break
            }
            
            if (proto == Protocols.socket){
                for port in ports {
                    do {
                        let socket = try Socket.create()
                        try socket.connect(to: ip, port: Int32(port), timeout: 200)
                        print("\(ip):\(port) - (Feat: \(feat) - connected?): \(socket.isConnected)")
                        features.append(feat)
                        if feat == .ps3mapi() {
                            name = "Playstation 3"
                            platform = PlatformType.ps3()
                            print(try socket.readString() ?? "first")
                            print(try socket.readString() ?? "second")
                        }
                        if feat == .orbisapi() || feat == .klog() {
                            name = "Playstation 4"
                            platform = PlatformType.ps4()
                        }
                        
                        if self.map[ip] == nil {
                            self.map[ip] = [feat: socket]
                        } else if(self.map[ip]![feat] == nil) {
                            self.map[ip]![feat] = socket
                        } else if(!self.map[ip]![feat]!.isConnected){
                            self.map[ip]![feat] = socket
                        } else {
                            socket.close()
                        }
                    } catch {
                        //print("FUCK: \(error)")
                    }
                }
                continue
            }
            else if(proto == Protocols.http) {
                if (true) {
                    continue
                }
                for port in ports {
                    SyncService.psx.getRequest(url: "http://\(ip):\(port)/") { data in
                        do {
                            if let result = try data.result.get() {
                                let response = String(decoding: result, as: UTF8.self)
                                let validated = Feature.validateResponse(s: response)
                                print("\(feat): validated")
                                if(validated){
                                    features.append(feat)
                                }
                            }
                        }catch {
                            print("Error: \(error)")
                        }
                    }
                }
            }
            else if(proto == Protocols.ftp) {
                    
            }
        }
        if !features.isEmpty {
            console.type = platform
            console.features = features
            console.name = name
            print("Found console \(console)")
            return console
        }
        return nil
    }
}


class Payload {
    static let socket = try! Socket.create()
    
    static func Payload(addr: String, port: Int32, payload: Data) -> (str: String?, sucess: Bool) {
        do {
            try socket.connect(to: addr, port: port)
            print("connected to PS4")
            do {
                print("sending payload to PS4")
                try socket.write(from: payload)
                socket.close()
                return ("Sent payload to PS4", true)
            } catch let error {
                return ("Error sending payload to PS4 \(error)", false)
            }
        } catch let error {
            return ("Cannot connect to PS4 \(error)", false)
        }
    }
}

