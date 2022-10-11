//
//  File.swift
//  Mi
//
//  Created by Vonley on 10/9/22.
//

import Foundation
import Socket
import SwiftUI
import UIKit

struct Device: Decodable {
    let device: String
    let version: String
    let ip: String
}

extension Device {

    var versionClean: String {
        return version.replacingOccurrences(of: ".", with: "")
    }
    
    var versionExt: String {
        if version.isEmpty {
            return ""
        } else if isPS4 {
            return ".\(versionClean)"
        } else if isPS5 {
            return ".ps5"
        } else {
            return ""
        }
    }
    
    var isPS4: Bool {
        return device == "PlayStation 4"
    }
    
    var isPS5: Bool {
        return device == "PlayStation 5"
    }
    
    

    
    
    var supported: Bool {
        if isPS5 {
            switch version {
                case "4.03":
                    return true
                case "4.50":
                    return true
                case "4.51":
                    return true
                default:
                    return false
            }
        } else if isPS4 {
            switch version {
                case "5.05":
                    return false
                case "6.72":
                    return false
                case "7.02":
                    return false
                case "7.50":
                    return false
                case "7.51":
                    return false
                case "7.55":
                    return false
                case "9.00":
                    return true
                default:
                    return false
            }
        }
        return false
    }
    
    static func parse(headers: [String: String]) -> Device {
        let testString = (headers["user-agent"] ?? "").strip()
        let ipAddr = (headers["host"] ?? "0.0.0.0").strip()
        let extractPlaystation =  #"\(([^()]*)\)"#.asRegex()
        let extractVersion = "([0-9]+(?:\\.[0-9]+)?)".asRegex()
        let matches = testString.matches(regex: extractPlaystation)
        let result: [[String]] = matches.find(testString: testString)
        if let matchEntire = result.flatMap { $0 }.filter({ $0.localizedCaseInsensitiveContains("playstation") }).first {
            let versionMatch = matchEntire.matches(regex: extractVersion)
            let versionResult = versionMatch.find(testString: matchEntire)
            if let version = versionResult.flatMap { $0 }.filter({ $0.count > 1 }).first {
                let rep = matchEntire
                    .replacingOccurrences(of: "playstation", with: "", options: String.CompareOptions.caseInsensitive)
                    .replacingOccurrences(of: ";", with: "")
                    .replacingOccurrences(of: "/", with: "")
                    .replacingOccurrences(of: version, with: "")
                let device = Device(device: "PlayStation \(rep.strip())", version: version, ip: ipAddr)
                debugPrint(device)
                return device
            }
            return Device(device: "PlayStation ?", version: "", ip: ipAddr)
        } else {
            return Device(device: "unknown", version: "", ip: ipAddr)
        }
    }
}

func handleGetRequest(socket: Socket, path: String, headers: [String: String], content: String) async {
    let device = Device.parse(headers: headers)
    debugPrint(headers)
    if let ext = URL(string: path) {
        var file: String
        if path == "/" {
            file = "index.html"
        } else {
            file = (ext.lastPathComponent)
        }
        
        if device.supported {
            if file != "mi.js" {
                file = "\(file)\(device.versionExt)"
                debugPrint("Supported-MiJS: \(file)")
            } else {
                debugPrint("Supported+MiJS: \(file)")
            }
            if let data = NSDataAsset(name: file)?.data {
                if let result = String(data: data, encoding: .utf8) {
                    if file.contains("index.html") {
                        let real = result.replacingOccurrences(of: "{{TITLE}}", with: Constants.TITLE)
                            .replacingOccurrences(of: "{{BODY}}", with: Constants.BODY)
                        try? socket.write(from: "HTTP/1.1 200 OK\r\nContent-Length: \(real.count)\r\n\r\n\(real)\r\n0\r\n\r\n")
                    } else {
                        try? socket.write(from: "HTTP/1.1 200 OK\r\nContent-Length: \(result.count)\r\n\r\n\(result)\r\n0\r\n\r\n")
                    }
                } else {
                    try? socket.write(from: "HTTP/1.1 200 OK\r\nContent-Length: \(data.count)\r\n\r\n")
                    try? socket.write(from: data)
                }
                return
            } else {
                debugPrint("FILE DOES NOT EXIST: \(file)")
            }
        } else {
            
            debugPrint("Not Supported: \(file)")
            if let data = NSDataAsset(name: file)?.data {
                if let result = String(data: data, encoding: .utf8) {
                    if file.contains("index.html") {
                        let real = result.replacingOccurrences(of: "{{TITLE}}", with: Constants.TITLE)
                            .replacingOccurrences(of: "{{BODY}}", with: "Unsupported device...<p>Coming back on a PS4/5</p>")
                        try? socket.write(from: "HTTP/1.1 200 OK\r\nContent-Length: \(real.count)\r\n\r\n\(real)\r\n0\r\n\r\n")
                    } else {
                        try? socket.write(from: "HTTP/1.1 200 OK\r\nContent-Length: \(result.count)\r\n\r\n\(result)\r\n0\r\n\r\n")
                    }
                }
            }
        }
    }
}

enum Minum: String, Codable {
    case started = "jb.started"
    case success = "jb.success"
    case failed = "jb.failed"
    case continuee = "jb.continue"
    case payload = "send.payload"
    case payloadReq = "send.payload.request"
    case pending = "send.pending"
}

struct MiCmd: Decodable {
    let cmd: Minum
}

struct MiResponse: Decodable {
    let response: String
    let data: MiCmd
    var device: Device? = nil
}

extension MiResponse: Identifiable {
    var id: String {
        return UUID().uuidString
    }
}

extension Minum {
    var bg: Color {
        switch self {
        case .success:
            return Color("mi.green")
        case .failed:
            return Color("mi.red")
        case .payload:
            return Color("mi.blue")
        case .pending:
            return Color("mi.orange")
        case .started:
            return Color("mi.blue")
        case .continuee:
            return Color("mi.purple")
        case .payloadReq:
            return Color("mi.yellow")
        }
    }
}


func handlePostRequest(socket: Socket, path:String, headers: [String: String], content: String) async {
    let device = Device.parse(headers: headers)
    debugPrint(headers)
    debugPrint(content)
    debugPrint(path)
    
    if path == "/jb/cmd" {
        let json = Data(content.utf8)
        do {
            let decode = JSONDecoder()
            var miCmd = try decode.decode(MiResponse.self, from: json)
            let repJson = #"{ "response": "thanks", "data": null }"#
            let response: Data = Data("HTTP/1.1 200 OK\r\nContent-Length: \(repJson.count)\r\n\r\n\(repJson)\r\n0\r\n\r\n".utf8)
            await MainActor.run {
                if var o = try? decode.decode(MiResponse.self, from: json) {
                    o.device = device
                    SyncServiceImpl.shared.logs.append(o)
                }
            }
            switch miCmd.data.cmd {
            case .success:
                break
            case .failed:
                break
            case .payload:
                if let gh = Constants.goldhen {
                    Goldhen.uploadData(data: gh)
                } else if let gh = NSDataAsset(name: "gh.js")?.data {
                    Goldhen.uploadData(data: gh) // 2.2.4
                }
                break
            case .pending:
                if let gh = Constants.goldhen {
                    Goldhen.uploadData(data: gh)
                } else if let gh = NSDataAsset(name: "gh.js")?.data {
                    Goldhen.uploadData(data: gh) // 2.2.4
                }
                break
            case .started:
                break
            case .continuee:
                break
            case .payloadReq:
                break
            }
            try? socket.write(from: response)
        }catch {
            
            try? socket.write(from: json)
        }
    }
    socket.close()
}

func handleWebClient(client: Socket) async {
    while(client.isConnected) {
        if let str = try? client.readString() {
            let content = str.components(separatedBy: "\r\n\r\n")
            let headers = content[0].components(separatedBy: "\r\n")
            var typeOfRequest: String = ""
            var o: [String: String] = [:]
            headers.forEach({ str in
                let split = str.split(separator: ":")
                if split.count > 1 {
                    o[String(describing: split[0]).lowercased()] =  String(describing: split[1])
                } else {
                    typeOfRequest = String(describing: split[0])
                }
            })
            
            
            if typeOfRequest.starts(with: "GET") {
                var path = typeOfRequest.replacingOccurrences(of: "GET ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                await handleGetRequest(socket: client, path: path, headers: o, content: content[1])
            } else if typeOfRequest.starts(with: "POST") {
                var path = typeOfRequest.replacingOccurrences(of: "POST ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                await handlePostRequest(socket: client, path: path, headers: o, content: content[1])
            }
            client.close()
        } else {
            
        }
    }
}

func ok () async {
    do {
        let socket = try Socket.create()
        try socket.listen(on: 29999)
        while (socket.isListening) {
            if let client = try? socket.acceptClientConnection() {
                Task {
                    await handleWebClient(client: client)
                }
            }
        }
    } catch {
        
    }
}
