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

enum Method: String {
    case head = "HEAD", get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

struct MiRequest {
    let socket: Socket
    let method: Method
    let path: String
    let content: String
    let headers: [String: String]
    let device: Device
}

enum Minum: String, Codable {
    case initiated = "jb.initiated"
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
        case .initiated:
            return Color("secondary")
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

struct MiServerResponse  {
    let status: Int
    let contentType: String
    let data: Data
}

extension MiServerResponse {
    
    func generate() -> Data {
        var content: String
        if contentType.isEmpty {
            content = "HTTP/1.1 \(status) OK\r\nContent-Length: \(data.count)\r\n\r\n"
        } else {
            content = "HTTP/1.1 \(status) OK\r\nContent-Type: \(contentType)\r\nContent-Length: \(data.count)\r\n\r\n"
        }
        var gen = Data(content.utf8)
        gen.append(self.data)
        return gen
    }
}


protocol MiServer {
    var port: Int { get  }
    func handleRequest(request: MiRequest) async -> MiServerResponse
    func start()
    func stop()
}

class MiServerImpl: ObservableObject,  MiServer {
    
    func stop() {
        self.server?.close()
        task?.cancel()
    }
    
    var port: Int = 8080
    
    static let port: Int = 8080
    
    func handleRequest(request: MiRequest) async -> MiServerResponse {
        var response = MiServerResponse(status: 500, contentType: "", data: Data())
        switch request.method {
        case .head:
            
            break
        case .get:
            response = await self.handleGetRequest(request: request)
            break
        case .post:
            response = await self.handlePostRequest(request: request)
            break
        case .put:
            break
        case .delete:
            break
        }
        return response
    }
    
    init() {
        
    }
    deinit {
        stop()
    }

    var task: Task<(), Never>? = nil
    var server: Socket? = nil
    
    func start () {
        self.task = Task(priority: .background) {
            do {
                self.server = try Socket.create()
                try server?.listen(on: port)
                while (server?.isListening == true) {
                    if let client = try? server?.acceptClientConnection() {
                        Task(priority: .background) {
                            await self.handleWebClient(client: client)
                        }
                    }
                }
            } catch {
                print("Mi Server: \(error.localizedDescription)")
            }
        }
    }

    private func handleGetRequest(request: MiRequest) async -> MiServerResponse {
        if let ext = URL(string: request.path) {
            var file: String
            if request.path == "/" {
                file = "index.html"
            } else {
                file = (ext.lastPathComponent)
            }
            
            if request.device.supported {
                if file != "mi.js" {
                    file = "\(file)\(request.device.versionExt)"
                }
                if let data = NSDataAsset(name: file)?.data {
                    if let result = String(data: data, encoding: .utf8) {
                        if file.contains("index.html") {
                            let real = result.replacingOccurrences(of: "{{TITLE}}", with: Constants.TITLE).replacingOccurrences(of: "{{BODY}}", with: Constants.BODY)
                            return MiServerResponse(status: 200, contentType: "", data: Data(real.utf8))
                        } else {
                            return MiServerResponse(status: 200, contentType: "", data: Data(result.utf8))
                        }
                    }
                    return MiServerResponse(status: 200, contentType: "", data: data)
                }
            }
            if let data = NSDataAsset(name: file)?.data {
                if let result = String(data: data, encoding: .utf8) {
                    if file.contains("index.html") {
                        let real = result.replacingOccurrences(of: "{{TITLE}}", with: Constants.TITLE)
                            .replacingOccurrences(of: "{{BODY}}", with: Constants.ERROR_CONTENT)
                        return MiServerResponse(status: 200, contentType: "text/html", data: Data(real.utf8))
                    } else {
                        return MiServerResponse(status: 200, contentType: "text/html", data: Data(result.utf8))
                    }
                } else {
                    return MiServerResponse(status: 200, contentType: "", data: data)
                }
            }
        }
        return MiServerResponse(status: 500, contentType: "text/html", data: Data())
    }

    private func handlePostRequest(request: MiRequest) async -> MiServerResponse {
        var repJson = #"{ "response": "request not handled", "data": null }"#
        if request.path == "/jb/cmd" {
            let json = Data(request.content.utf8)
            do {
                let decode = JSONDecoder()
                let status = 200
                let miCmd = try decode.decode(MiResponse.self, from: json)
                repJson = #"{ "response": "thanks", "data": null }"#
                await MainActor.run {
                    if var o = try? decode.decode(MiResponse.self, from: json) {
                        o.device = request.device
                        if SyncServiceImpl.shared.logs.count > 6 {
                            SyncServiceImpl.shared.logs.removeFirst()
                        }
                        SyncServiceImpl.shared.logs.append(o)
                    }
                }
                switch miCmd.data.cmd {
                case .initiated:
                    break
                case .success:
                    break
                case .failed:
                    break
                case .payload:
                    Task(priority: .background) {
                        if let gh = Constants.goldhen {
                            await Goldhen.uploadData(data: gh)
                        } else if let gh = NSDataAsset(name: "gh.bin.\(request.device.versionClean)")?.data {
                            await Goldhen.uploadData(data: gh) // 2.2.4
                        }
                    }
                    break
                case .pending:
                    if let gh = Constants.goldhen {
                        let result = Payload.send(addr: request.device.ip, port: 9020, payload: gh)
                        print(result)
                        if result.1 {
                            await MainActor.run {
                                if SyncServiceImpl.shared.logs.count > 6 {
                                    SyncServiceImpl.shared.logs.removeFirst()
                                }
                                
                                SyncServiceImpl.shared.logs.append(MiResponse(response: "Payload sent!", data: MiCmd(cmd: .success), device: request.device))
                            }
                        }
                    } else if let gh = NSDataAsset(name: "gh.bin.\(request.device.versionClean)")?.data {
                        let result = Payload.send(addr: request.device.ip, port: 9020, payload: gh) //2.2.4
                        print(result)
                        if result.1 {
                            await MainActor.run {
                                if SyncServiceImpl.shared.logs.count > 6 {
                                    SyncServiceImpl.shared.logs.removeFirst()
                                }
                                SyncServiceImpl.shared.logs.append(MiResponse(response: "Payload sent!", data: MiCmd(cmd: .success), device: request.device))
                            }
                        }
                    }
                    break
                case .started:
                    break
                case .continuee:
                    break
                case .payloadReq:
                    break
                }
                return MiServerResponse(
                    status: status,
                    contentType: "application/json",
                    data: Data(repJson.utf8)
                )
            } catch {
                print("MiServer:Post:Error \(error)\n \(error.localizedDescription)")
            }
        }
        return MiServerResponse(status: 500, contentType: "application/json", data: Data(repJson.utf8))
    }

    
    private func handleWebClient(client: Socket) async {
        while(client.isConnected) {
            if let str = try? client.readString() {
                let content = str.components(separatedBy: "\r\n\r\n")
                let headerSeparated = content[0].components(separatedBy: "\r\n")
                var typeOfRequest: String = ""
                var headers: [String: String] = [:]
                headerSeparated.forEach({ str in
                    let split = str.split(separator: ":")
                    if split.count > 1 {
                        headers[String(describing: split[0]).lowercased()] =  String(describing: split[1])
                    } else {
                        typeOfRequest = String(describing: split[0])
                    }
                })
                
                var request: MiRequest
                
                if typeOfRequest.starts(with: "GET") {
                    let path = typeOfRequest.replacingOccurrences(of: "GET ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                    request = MiRequest(socket: client, method: .get, path: path, content: content[1], headers: headers, device: Device.parse(client: client, headers: headers))
                } else if typeOfRequest.starts(with: "POST") {
                    let path = typeOfRequest.replacingOccurrences(of: "POST ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                    request = MiRequest(socket: client, method: .post, path: path, content: content[1], headers: headers, device: Device.parse(client: client, headers: headers))
                } else if typeOfRequest.starts(with: "HEAD") {
                    let path = typeOfRequest.replacingOccurrences(of: "HEAD ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                    request = MiRequest(socket: client, method: .head, path: path, content: content[1], headers: headers, device: Device.parse(client: client, headers: headers))
                } else if typeOfRequest.starts(with: "DELETE") {
                    let path = typeOfRequest.replacingOccurrences(of: "DELETE ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                    request = MiRequest(socket: client, method: .delete, path: path, content: content[1], headers: headers, device: Device.parse(client: client, headers: headers))
                } else if typeOfRequest.starts(with: "PUT") {
                    let path = typeOfRequest.replacingOccurrences(of: "PUT ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                    request = MiRequest(socket: client, method: .put, path: path, content: content[1], headers: headers, device: Device.parse(client: client, headers: headers))
                } else {
                    client.close()
                    return
                }
                
                debugPrint("Request: \(request)")
                do {
                    let response = await self.handleRequest(request: request)
                    try client.write(from: response.generate())
                    client.close()
                } catch {
                    print("Response Error: \(error.localizedDescription)")
                }
            } else {
                break
            }
        }
    }

}

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
    
    static func parse(client: Socket, headers: [String: String]) -> Device {
        let testString = (headers["user-agent"] ?? "").strip()
        let ipAddr = (client.remoteHostname ?? "0.0.0.0").strip()
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
