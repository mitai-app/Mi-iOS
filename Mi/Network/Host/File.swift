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

enum paths: String {
    case netcat = "/jb/900/netcat.js"
    case index = "/jb/900/index.html"
    case payload = "/jb/900/payload.html"
    case fakeusb = "/jb/900/fakeusb.js"
    case ftp = "/jb/900/ftp.js"
    case jbhtml = "/jb/900/jb.html"
    
    case kexploit_launcher = "/jb/900/kexploit-launcher.js"
    case kexploit_rop = "/jb/900/kexploit/rop.js"
    case kexploit_int64 = "/jb/900/kexploit/int64.js"
    case kexploit_js = "/jb/900/kexploit/kexploit.js"
    case kexplor_webkit = "/jb/900/kexploit/webkit.js"
    case kexploit_index = "/jb/900/kexploit/index.html"
    
    case manifest = "/jb/900/Cache.manifest"
    case mira1 = "/jb/900/mira/mira.js"
    case mira2 = "/jb/900/mira/mira2.js"
    
    case webkit = "/jb/900/webkit-9.00/exploit.js"
    case malloc = "/jb/900/webkit-9.00/malloc.js"
    case rop = "/jb/900/webkit-9.00/rop/rop.js"
    
    case syscalls = "/jb/900/common/syscalls.js"
    case syscalls2 = "/jb/900/common/syscalls2.js"
    case relocator = "/jb/900/common/relocator.js"
    case mijs = "/jb/900/common/mi.js"
}

struct Device {
    let device: String
    let version: String
    let ip: String
}

extension Device {

    var versionClean: String {
        return version.replacingOccurrences(of: ".", with: "")
    }
    
    var jbPath: String {
        switch (version) {
        case "5.05":
            return "jb/505"
        case "6.72":
            return "jb/672"
        case "7.02":
            return "jb/702"
        case "7.50":
            return "jb/75x"
        case "7.51":
            return "jb/75x"
        case "7.55":
            return "jb/75x"
        case "9.00":
            return "jb/900"
        default:
            return "pages/fail.html"
            break
        }
    }
    
    var supported: Bool {
        switch version {
            case "5.05":
                return true
            case "6.72":
                return true
            case "7.02":
                return true
            case "7.50":
                return true
            case "7.51":
                return true
            case "7.55":
                return true
            case "9.00":
                return true
            default:
                return false
        }
    }
}

func parse(headers: [String:String]) -> Device {
    let testString = headers["user-agent"] ?? ""
    
    let extractPlaystation =  #"\(([^()]*)\)"#
    let extractVersion = "([0-9]+(?:\\.[0-9]+)?)"
    let regex = try! NSRegularExpression(pattern: extractPlaystation, options: .anchorsMatchLines)
    let stringRange = NSRange(location: 0, length: testString.utf16.count)
    let matches = regex.matches(in: testString, range: stringRange)
    var result: [[String]] = []
    for match in matches {
        var groups: [String] = []
        for rangeIndex in 1 ..< match.numberOfRanges {
            let nsRange = match.range(at: rangeIndex)
            guard !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) else { continue }
            let string = (testString as NSString).substring(with: nsRange)
            groups.append(string)
        }
        if !groups.isEmpty {
            result.append(groups)
        }
    }
    
//    let matchEntire = extractPlaystation.findAll(string).flatMap { it.groupValues }.distinct()
//        .filter { it.contains("playstation", true) }.toList().firstOrNull();
//    if (matchEntire != null) {
//        println(matchEntire)
//        val extracted =
//            extractVersion.findAll(matchEntire).flatMap { it.groupValues }.distinct().toList()
//        val version = extracted.last()
//        return Device(matchEntire, version, session.headers["http-client-ip"] ?: "0.0.0.0")
//    }
    return Device(device: "Playstation", version: "9.00", ip: "192.168.11.45")
}

func handleGetRequest(socket: Socket, path: String, headers: [String: String], content: String) {
    let device = parse(headers: headers)
    if let ext = URL(string: path) {
        var file: String
        if path == "/" {
            file = "index.html.\(device.versionClean)"
        } else {
            file = "\(ext.lastPathComponent).\(device.versionClean)"
        }
        debugPrint(file)
        if let data = NSDataAsset(name: file)?.data {
            let result = String(data: data, encoding: .utf8)
            try? socket.write(from: "HTTP/1.1 200 OK\r\nContent-Length: \(result!.count)\r\n\r\n\(result!)\r\n0\r\n\r\n")
        } else {
            debugPrint("Eh")
        }
    } else {
        let resource = "webserver/assets/\(device.jbPath)/ ...hmmm"
        debugPrint(resource)
    }
    
}

func handlePostRequest(typeOfRequest:String, headers: [String: String], content: String) {
    
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
                handleGetRequest(socket: client, path: path, headers: o, content: content[1])
            } else if typeOfRequest.starts(with: "POST") {
                var path = typeOfRequest.replacingOccurrences(of: "POST ", with: "").replacingOccurrences(of: " HTTP/1.1", with: "")
                handlePostRequest(typeOfRequest: path, headers: o, content: content[1])
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
