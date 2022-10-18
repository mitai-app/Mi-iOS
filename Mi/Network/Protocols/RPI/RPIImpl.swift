//
//  RPIImpl.swift
//  Mi
//
//  Created by Vonley on 10/15/22.
//

import Foundation
import Socket
import SwiftUI
import Alamofire

extension String {
    func pr() {
        print(self)
    }
}

struct RPIRequest {
    let method: Method
    let path: String
    let headers: [String: String]
    let content: String
    let param: String
}

struct RPIResponse {
    let status: Int
    let content: Data
    private let contentType: String = "application/x-newton-compatible-pkg"
}

struct PKG {
    let name: String
    let data: Data
    var status: Int = 0
    var taskId: Int = -1
    var progress: RPIProgress? = nil
}

enum RPIType: String, Codable {
    case direct = "direct"
    case ref_pkg_url = "ref_pkg_url"
}
struct RpiPkgRequest: Encodable {
    let type: RPIType
    let packages: [String]?
    let url: String?
}

extension RpiPkgRequest {
    static func ref(url: String) -> RpiPkgRequest {
        return RpiPkgRequest(type: .ref_pkg_url, packages: nil, url: url)
    }

    static func direct(urls: [String]) -> RpiPkgRequest {
        return RpiPkgRequest(type: .direct, packages: urls, url: nil)
    }
}

//{ "status": "success", "task_id": 1178, "title": "Grand Theft Auto V" }
//{ "status": "success", "bits": 0x20C, "error": 0, "length": 0x8F01B0000, "transferred": 0x8F01B0000, "length_total": 0x8F01B0000, "transferred_total": 0x8F01B0000, "num_index": 1, "num_total": 1, "rest_sec": 0, "rest_sec_total": 0, "preparing_percent": 100, "local_copy_percent": 100 }
struct GetProccessRequest: Encodable {
    let task_id: Int
}
struct RPITask: Decodable {
    let status: String
    let task_id: Int
    let title: String
}

struct RPIProgress: Decodable {
    let status: String
    let bits: Int
    let error: Int
    let length: Int64
    let transfered: Int64
    let lengthTotal: Int64
    let transferred_total: Int64
    let num_index: Int
    let num_total: Int
    let rest_sec: Int
    let rest_sec_total: Int
    let preparing_percent: Int
    let local_copy_percent: Int
}

class RPIImpl : RPI, ObservableObject {
    
    func getTaskProcess(name: String, taskId: Int, progressCallback: @escaping (RPIProgress) -> Void) {
        if let target = SyncServiceImpl.shared.target {
            if let url = URL(string: "http://\(target.ip):12800/api/get/get_task_progress") {
                if self.payloads.keys.contains("/\(name)") {
                    if taskId == self.payloads["/\(name)"]!.taskId {
                        let build = GetProccessRequest(task_id: taskId)
                        let jsonData = try! self.encoder.encode(build)
                        var request = URLRequest(url: url)
                        request.httpMethod = HTTPMethod.post.rawValue
                        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                        request.httpBody = jsonData
                        AF.request(request).response { response in
                                guard let data = response.data else { return }
                                switch response.result {
                                case .success(_):
                                    do {
                                        let rpiJson = try self.decoder.decode(RPIProgress.self, from: data)
                                        progressCallback(rpiJson)
                                    } catch {
                                        
                                    }
                                    break
                                case .failure(_):
                                    print(String(data: data, encoding: .utf8) ?? "WTF")
                                    break
                                }
                            
                        }
                    }
                }
            }
        }
            
    }
    
    func sendRefPkgUrlRequest(ref_url: String, onSent: @escaping (Data) -> Void, onError: @escaping (Data) -> Void) {
        if let target = SyncServiceImpl.shared.target {
            if let url = URL(string: "http://\(target.ip):12800/api/install") {
                Task(priority: .background) {
                    let build = RpiPkgRequest.ref(url: ref_url)
                    let encoder = JSONEncoder()
                    let jsonData = try! encoder.encode(build)
                    var request = URLRequest(url: url)
                    request.httpMethod = HTTPMethod.post.rawValue
                    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    AF.request(request).response { response in
                        Task(priority: .background) {
                            guard let data = response.data else { return }
                            switch response.result {
                            case .success(_):
                                await MainActor.run {
                                    onSent(data)
                                }
                                break
                            case .failure(_):
                                await MainActor.run {
                                    onError(data)
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sendDirectRequest(urls: [String], onSent: @escaping (Data) -> Void, onError: @escaping (Data) -> Void) {
        if let target = SyncServiceImpl.shared.target {
            if let url = URL(string: "http://\(target.ip):12800/api/install") {
                
                    let build = RpiPkgRequest.direct(urls: urls)
                    let jsonData = try! self.encoder.encode(build)
                    var request = URLRequest(url: url)
                    request.httpMethod = HTTPMethod.post.rawValue
                    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    
                    AF.request(request).response { response in
                            guard let data = response.data else { return }
                            switch response.result {
                            case .success(_):
                                do {
                                    let rpiJson = try self.decoder.decode(RPITask.self, from: data)
                                    if let url = URL(string: urls[0]) {
                                        let file = url.lastPathComponent
                                        if self.payloads.keys.contains("/\(file)")  {
                                            self.payloads["/\(file)"]!.taskId = rpiJson.task_id
                                        }
                                    }
                                    onSent(data)
                                } catch {
                                    
                                }
                                break
                            case .failure(_):
                                    onError(data)
                                break
                            }
                        
                    }
                
            }
        }
    }
    
    let encoder = JSONEncoder()
    let decoder: JSONDecoder = JSONDecoder()
    let localDeviceIp = "192.168.11.229"
    @Published
    var payloads: [String: PKG] = [:]
    private var server: Socket?
    private var port: Int = 8081
    static let port: Int = 8081
    private let debug: Bool = true

    private func handleClient(client: Socket) {
        let rpi = parse(client: client)
        let response = handleConnection(rpi: rpi)
        do {
            try client.write(from: generate(request: rpi, response: response))
        } catch {
            error.localizedDescription.pr()
        }
        client.close()
        if payloads.keys.contains(rpi.path) {
            if let p = payloads[rpi.path] {
                if(p.taskId > 0) {
                    self.getTaskProcess(name: p.name, taskId: p.taskId) { progress in
                        self.payloads[rpi.path]!.progress = progress
                    }
                }
            }
        }
    }
    
    private func parse(client: Socket) -> RPIRequest {
        
        var bytes = Data()
        
        let bytesRead = try? client.read(into: &bytes)
        let sb = String(data: bytes, encoding: .utf8) ?? ""
        if (debug) {
            sb.pr()
            "Bytes read: \(String(describing: bytesRead))".pr()
        }
        let split = sb.components(separatedBy: "\r\n\r\n")
        let headerString = split[0]
        let contentString = (split.count > 1) ? split[1] : ""
        var headersArray = headerString.components(separatedBy: "\r\n")
        let request = headersArray.removeFirst()
        
        var headers: [String: String] = [:]
        
        headersArray.forEach { header in
            let pairs = header.components(separatedBy: ": ")
            headers[pairs[0].lowercased()] = pairs[1]
        }
        
        /*mapOf(*headersArray.map {
            let pairs = it.split(": ")
            return@map Pair(pairs[0].lowercase(), pairs[1])
        }.toTypedArray())*/
        
        
        
        
        //let keepAlive = headers.keys.contains("connection") && headers["connection"]!.contains("Keep-Alive")
        //client.keepAlive = keepAlive
        
        if request.starts(with: "GET") {
            var path = request.replacingOccurrences(of: "GET ", with: "")
                .replacingOccurrences(of: " HTTP/1.1", with: "")
                .replacingOccurrences(of: " HTTP/1.0", with: "")
                .replacingOccurrences(of: " HTTP/2.0", with: "")
            var params: String
            if (path.contains("?")) {
                let s = path.components(separatedBy: "?")
                path = s[0]
                params = s[1]
            } else {
                params = ""
            }
            return RPIRequest(method: Method.get, path: path, headers: headers, content: contentString, param: params)
        }
        if request.starts(with: "POST")  {
            let path = request.replacingOccurrences(of: "POST ", with: "")
                .replacingOccurrences(of: " HTTP/1.1", with: "")
                .replacingOccurrences(of: " HTTP/1.0", with: "")
                .replacingOccurrences(of: " HTTP/2.0", with: "")
            return RPIRequest(method: Method.post, path: path, headers: headers, content: contentString, param: "")
        } else if request.starts(with: "PUT")  {
            let path = request.replacingOccurrences(of: "PUT ",  with: "")
                .replacingOccurrences(of: " HTTP/1.1", with: "")
                .replacingOccurrences(of: " HTTP/1.0", with: "")
                .replacingOccurrences(of: " HTTP/2.0", with: "")
            return RPIRequest(method: Method.put, path: path, headers: headers, content: contentString, param: "")
        } else if request.starts(with: "DELETE") {
            let path = request.replacingOccurrences(of: "DELETE ", with: "")
                .replacingOccurrences(of: " HTTP/1.1", with: "")
                .replacingOccurrences(of: " HTTP/1.0", with: "")
                .replacingOccurrences(of: " HTTP/2.0", with: "")
            return RPIRequest(method: Method.delete, path: path, headers: headers, content: contentString, param: "")
        } else if request.starts(with: "HEAD") {
            let path = request.replacingOccurrences(of: "HEAD ", with:"")
                .replacingOccurrences(of: " HTTP/1.1", with: "")
                .replacingOccurrences(of: " HTTP/1.0", with: "")
                .replacingOccurrences(of: " HTTP/2.0", with: "")
            return RPIRequest(method: Method.head, path: path, headers: headers, content: contentString, param: "")
        } else {
            return RPIRequest(method: Method.head, path: request, headers: headers, content: contentString, param: "")
        }
    }
    
    private func generate(request: RPIRequest, response: RPIResponse) -> Data {
        func generateHeader(filename: String, start: Int, end: Int, totalBytes: Int) -> Data {
            let headers = [
                "HTTP/1.1 206 Partial Content",
                "X-Powered-By: Mi",
                "Access-Control-Allow-Origin: *",
                "Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, PATCH, DELETE",
                "Content-Disposition: attachment; filename=\"\(filename.replacingOccurrences(of: "/", with: ""))\"",
                "Accept-Ranges: bytes",
                "Cache-Control: public, max-age=0",
                "Last-Modified: Fri, 14 Oct 2022 16:52:07 GMT",
                "ETag: W/\"2140000-183d769035f\"",
                "Content-Type: application/octet-stream",
                "Content-Range: bytes \(start)-\(end)/\(totalBytes)",
                "Content-Length: \(end - start)",
                "Date: Fri, 14 Oct 2022 17:36:56 GMT",
                "Connection: keep-alive"
            ].joined(separator: "\r\n")
            return Data((headers + "\r\n\r\n").utf8)
        }

        if (request.headers.keys.contains("range")) {
            print("YES")
            let range = request.headers["range"]!
            let bytes = range.components(separatedBy: "=")[1]
            let split = bytes.components(separatedBy: "-")
            let from: Int = Int.init(split[0]) ?? 0
            var to: Int
            if split.count > 1 {
                if let t = Int.init(split[1]) {
                    to = t + 1
                } else {
                    to = response.content.count
                }
            } else  {
                to = response.content.count
            }
            

            let payload = response.content[from..<to] //.copyOfRange(from, to)
            let gen = generateHeader(filename: request.path, start: from, end: to, totalBytes: response.content.count)
            print("RESPONSE: \n" + (String(data: gen, encoding: .utf8) ?? ""))
            return gen + payload
        }

        let headers = Data("HTTP/1.1 \(response.status) OK\r\nContent-Length: \(response.content.count)\r\n\r\n".utf8)
        print("HEADERS:\n \(String(data: headers, encoding: .utf8) ?? "")")
        return headers + response.content
    }
    
    private func handleConnection(rpi: RPIRequest) -> RPIResponse {
        if (debug) {
            "PATH: \(rpi.path)".pr()
        }
        switch (rpi.method) {
        case .head: return handleHeadRequest(rpi: rpi)
        case .get: return handleGetRequest(rpi: rpi)
        case .post: return handlePostRequest(rpi: rpi)
        case .put: return handlePutRequest(rpi: rpi)
        case .delete: return handleDeleteRequest(rpi: rpi)
        }
    }
    
    private func handleGetRequest(rpi: RPIRequest) -> RPIResponse {
        print(rpi)
        if payloads.keys.contains(rpi.path) {
            let payload = payloads[rpi.path]!
            return RPIResponse(status: 200, content: payload.data)
        }
        else {
            return emptyResponse(rpi: rpi)
        }
    }
    
    private func handleHeadRequest(rpi: RPIRequest) -> RPIResponse {
        return emptyResponse(rpi: rpi)
    }
    
    private func handlePostRequest(rpi: RPIRequest) -> RPIResponse {
        return emptyResponse(rpi: rpi)
    }
    
    private func handlePutRequest(rpi: RPIRequest) -> RPIResponse {
        return emptyResponse(rpi: rpi)
    }
    
    private func handleDeleteRequest(rpi: RPIRequest) -> RPIResponse {
        return emptyResponse(rpi: rpi)
    }
    
    private func emptyResponse(rpi: RPIRequest) -> RPIResponse {
        let content = "HTTP/1.1 200 OK\r\nContent-Length: 0\r\nContent-Type: text/html\r\n\r\n"
        return RPIResponse(status: 200, content: Data(content.utf8))
    }

    var task: Task<(), Never>? = nil
    
    func start(port: Int = RPIImpl.port) {
        task?.cancel()
        self.task = Task(priority: .background) {
            do {
                if (self.server == nil) {
                    server = try Socket.create()
                    try server?.listen(on: port)
                    "Initializing RPI server".pr()
                    self.port = port
                    
                } else {
                    "RPI Server already started".pr()
                    return
                }
                while (server?.isListening == true) {
                    do {
                        if let client = try server?.acceptClientConnection() {
                            Task(priority: .background) {
                                "RPIImpl.swift::start -> handleClient: \(client.remoteHostname)".pr()
                                self.handleClient(client: client)
                            }
                        }
                    } catch {
                        "RPIImpl.swift::start -> Couldnt capture client: \(error.localizedDescription)".pr()
                    }
                }
            } catch {
                "RPIImpl.swift::start -> fail to init server: \(error.localizedDescription)".pr()
            }
        }
    }

    func hostPackage(payloads: PKG...) -> Array<String> {
        if let ip = SyncServiceImpl.shared.deviceIP {
            let urls: [String] = payloads.map { pkg in
                let path = pkg.name
                self.payloads["/"+path] = pkg
                return "http://\(ip):\(port)/\(path)"
            }
            return urls
        } else {
            return []
        }
    }

    public static let TAG = "RemotePackageInstaller"
    
}
