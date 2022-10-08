//
//  FTP.swift
//  Mi
//
//  Created by Vonley on 10/6/22.
//

import Foundation
import Socket
import FileProvider

struct FTPFile: Identifiable {
    
    var id: String {
        return "\(cwd)-\(name)"
    }
    let cwd: String
    let directory: Bool
    let permissions: String
    let nbfiles: Int
    let owner: String
    let group: String
    let size: Int
    let date: String
    let name: String
}
extension FTPFile {
    
    
    static func parse(cwd: String, testString: String) -> [FTPFile] {
        let patterns = #"^([\-ld])([\-rwxs]{9})\s+(\d+)\s+(.+)\s+(.+)\s+(\d+)\s+(\w{3}\s+\d{1,2}\s+(?:\d{1,2}:\d{1,2}|\d{4}))\s+(.+)$"#
        let pattern =  #"^([\-ld])([\-rwxs]{9})\s+(\d+)\s+(\w+)\s+(\w+)\s+(\d+)\s+(\w{3}\s+\d{1,2}\s+(?:\d{1,2}:\d{1,2}|\d{4}))\s+(.+)$"#
        let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
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
        var index = 0
        let res: [FTPFile] = result.map { array in
            
            let directory: Bool = array[0] == "d"
            let permisions: String = array[1]
            let nbfiles: Int = Int(array[2]) ?? 0
            let owner: String = array[3]
            let group: String = array[4]
            let size: Int = Int(array[5]) ?? 0
            let date: String = array[6]
            let name: String = array[7]
            let file = FTPFile(
                cwd: cwd,
                directory: directory,
                permissions:permisions,
                nbfiles: nbfiles,
                owner: owner,
                group: group,
                size: size,
                date: date,
                name: name
            )
            index += 1
            return file
        }
        debugPrint(res)
        return res.sorted { file1, file2 in
            if (file1.directory && file2.directory) {
                return file1.name.compare(file2.name) == ComparisonResult.orderedAscending
            } else if file1.directory {
                return true
            } else if file2.directory {
                return false
            } else {
                return false
            }
        }
    }
}

protocol FTPDelegate {
    func onList(dirs: [FTPFile])
}

class FTP: ObservableObject {
    
    var ip: String {
        if socket == nil {
            return ""
        }
        return socket.remoteHostname
    }
    
    var port: Int {
        if socket == nil {
            return 0
        }
        return Int(socket.remotePort)
    }
    
    var isConnected: Bool {
        if socket == nil {
            return false
        }
        return socket.isConnected
    }
    
    
    static func create(ip: String, port: Int, res: @escaping (String) -> Void) throws -> FTP {
        let socket = try Socket.create()
        try socket.connect(to: ip, port: .init(port))
        return create(socket: socket, res: res)
    }
    

    static func create(socket: Socket, res: @escaping (String) -> Void) -> FTP {
        return FTP(socket: socket, res: res)
    }
    
    static let shared: FTP = FTP()
    
    init() {
        
    }
    
    func setResponse(res: @escaping (String) -> Void) {
        self.res = res
    }
    
    func setHost(ip: String, port: Int) async -> Bool {
        guard let socket = try? Socket.create() else {
            return false
        }
        try? socket.connect(to: ip, port: Int32(port))
        
        if(socket.isConnected){
            self.socket = socket
            self.auth()
        }
        return socket.isConnected
    }

    
    func close() {
        if socket != nil {
            socket.close()
            data.close()
        }
    }
    
    init(socket: Socket, res: @escaping (String) -> Void) {
        self.socket = socket
        self.res = res
        self.auth()
    }


    var socket: Socket!
    private var data: Socket!
    private var dataPort: Int = 0
    private var res: ((String) -> Void)?
    
    var delegate: FTPDelegate?
    
    @Published var dir: [FTPFile] = []
    
    @Published var cwd: String = "/"

    var isAuthenticated: Bool = false
    
    
    func auth(anonymous: Bool = true) {
        do {
            var readBytes = try socket.readString()
            print("Intro: \(readBytes)")
            try socket.write(from: "USER anonymous\r\n")
            readBytes = try socket.readString()
            print("USER: \(readBytes)")
            try socket.write(from: "PASS anonymous\r\n")
            readBytes = try socket.readString()
            print("PASS: \(readBytes)")
            Task {
                await run()
            }
        } catch {
            
        }
    }

    func readFromDataSock() async {
        data = try! Socket.create()
        try! data.connect(to: socket.remoteHostname, port: Int32(dataPort))
        guard let bytes = try? data.readString() else {
            data.close()
            return
        }
        await MainActor.run {
            let dir = FTPFile.parse(cwd: cwd, testString: bytes)
            data.close()
            if dir.count == 1 {
                dir[0].name == "."
                Task {
                    await self.list()
                }
            } else {
                self.dir = dir
                delegate?.onList(dirs: dir)
                self.objectWillChange.send()
            }
        }

    }

    func write(_ string: String) async -> Bool {
        do {
            try socket.write(from: string)
            return true
        } catch {
            print(error)
            return false
        }
    }

    func handled(_ string: String) async -> Bool {
        let split = string.split(separator: " ", maxSplits: 1)
        if(split.count >= 2) {
            let code = Int.init(split[0]) ?? 0, message = split[1]
            print("RESONSE: \(code): \(message)")
            switch code {
            case 150: // Open Stream
                print(message)
                return true
            case 200: // OK
                print(message)
                return true
                
            case 215:
                print(message)
                return true
            case 226:
                // transfer complete
                return true
            case 227:
                let firstBrace = message.firstIndex(of: "(")
                let lastBrace = message.firstIndex(of: ")")
                let ipPort = String(message[firstBrace!..<lastBrace!])
                let parts = ipPort.split(separator: ",")
                let ip = "\(parts[0]).\(parts[1]).\(parts[2]).\(parts[3])"
                let port = (Int.init(parts[4]) ?? 0) * 256 + (Int.init(parts[5]) ?? 0)
                self.dataPort = port
                Task {
                    await self.readFromDataSock()
                }
                print("\(ip):\(port)")
                return true
            case 250:  // Request file action okay
                return true
            case 257:
                let firstBrace = message.firstIndex(of: "\"")!
                let lastBrace = message.lastIndex(of: "\"")!
                await MainActor.run {
                    self.cwd = String(message[firstBrace..<lastBrace])
                }
                return true
            case 502: // Not Implemented
                return true
            case 550: // Invalid Dir
                break
            default:
                print("Not Handled - \(code): \(message)")
                return false
            }
        }
        return false

    }

    func run() async {
        while (socket.isConnected) {
            do {
                let readAllBytes = try socket.readString()!
                print("READ: \(readAllBytes)")
                await self.handled(readAllBytes)
            } catch {
                print(error)
                break
            }
        }
    }
    
    
}

extension FTP {
    

    func pasv() async-> Bool {
        return await write("PASV\r\n")
    }

    func list() async -> Bool {
        let a = await pasv()
        let b = await write("LIST\r\n")
        return a && b
    }

    func cdup() async -> Bool {
        let a = await write("CDUP\r\n")
        let b = await pwd()
        return a && b
    }

    func mkd(dir: String) async -> Bool {
        let a = await write("MKD \(dir)\r\n")
        let b = await pwd()
        return a && b
    }
    func delete(filename: String) async -> Bool {
        return await write("DELE \(filename)\r\n")
    }

    func pwd() async -> Bool {
        return await write("PWD\r\n")
    }

    func cwd(dir: String) async -> Bool {
        return await write("CWD \(dir)\r\n")
    }


    func noop()async-> Bool {
        return await write("NOOP\r\n")
    }

    func quit() async -> Bool {
        return await write("QUIT\r\n")
    }

    func rest(position: Int = 0) async -> Bool {
        return await write("REST \(position)\r\n")
    }

    func systemType() async -> Bool {
        return await write("SYST")
    }

    enum MODE: String {
        case I = "I", F = "F", S = "S"
    }

    func type(mode: MODE) async -> Bool {
        return await write("TYPE \(mode.rawValue)")
    }

    func structure() async -> Bool {
        return await write("STRU F")
    }

    func mode() async -> Bool {
        return await write("MODE S")
    }

    func stor(filename: String) async -> Bool {
        return await write("STOR \(filename)")
    }
}
