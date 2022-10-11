//
//  FTP.swift
//  Mi
//
//  Created by Vonley on 10/6/22.
//

import Foundation
import Socket
import FileProvider

class FTP: ObservableObject {
    
    
    @Published var dir: [FTPFile] = []
    @Published var cwd: String = "/"
    
    var delegate: FTPDelegate?
    
    private var socket: Socket!
    private var data: Socket!
    private var server: Socket!
    private var isAuthenticated: Bool = false
    private var action: ActionData = ActionData.init(
        action: .none,
        name: "",
        data: Data()
    )
    private var ip: String {
        if socket == nil {
            return ""
        }
        return socket.remoteHostname
    }
    private var isConnected: Bool {
        if socket == nil {
            return false
        }
        return socket.isConnected
    }
    private var port: Int {
        if socket == nil {
            return -1
        }
        return Int(socket.remotePort)
    }
    private var serverPort: Int = 35211
    private var dataPort: Int = 0
    private var delay: UInt64 = 500_000_000
    private var runThread: Task<(), Never>?
    private var readDataThread: Task<(), Never>?
    private var serverThread: Task<Bool, Never>?
    
    init () {
        
    }
    
    init (socket: Socket) {
        self.socket = socket
        self.auth()
    }
    
    
    func setHost(ip: String, port: Int) async -> Bool {
        guard let socket = try? Socket.create() else {
            return false
        }
        do {
            try socket.connect(to: ip, port: Int32(port), timeout: 500)
            await close()
            if(socket.isConnected){
                self.socket = socket
                self.auth()
            }
            return socket.isConnected
        } catch {
            #if DEBUG
            debugPrint(error.asAFError?.errorDescription ?? "something wrong")
            debugPrint(error.localizedDescription)
            #endif
        }
        return false
    }

    func clean() async {
        serverThread?.cancel()
        if let server = self.server {
            if server.isActive {
                clients.forEach { (key: Task<(), Never>, value: Socket) in
                    value.close()
                    key.cancel()
                }
                server.close()
                clients.removeAll()
            }
        }
        self.server = nil
        
        readDataThread?.cancel()
        if let data = self.data {
            if data.isConnected {
                data.close()
            }
            self.data = nil
        }
    }
    
    func close() async {
        return await destroy()
    }
    
    private func destroy() async {
        runThread?.cancel()
        serverThread?.cancel()
        readDataThread?.cancel()
        isAuthenticated = false
        if let server = self.server {
            if server.isActive {
                clients.forEach { (key: Task<(), Never>, value: Socket) in
                    value.close()
                    key.cancel()
                }
                server.close()
                clients.removeAll()
            }
            self.server = nil
        }
        if let sock = self.socket {
            if sock.isConnected {
                do {
                    var (r, w) = try sock.isReadableOrWritable()
                    if (r || w) {
                        print("Why are you still readable(\(r)) and writable(\(w))?")
                        sock.close()
                        (r, w) = try sock.isReadableOrWritable()
                        print("readable(\(r))? writable(\(w))?")
                    }
                } catch {
                    #if DEBUG
                    debugPrint(error.asAFError?.errorDescription ?? "something up")
                    debugPrint(error.localizedDescription)
                    #endif
                }
            }
            self.socket = nil
        }
        
        if let data = self.data {
            if data.isConnected {
                data.close()
            }
            self.data = nil
        }
        
    }
    
    private func auth(anonymous: Bool = true) {
        do {
            var readBytes = try socket.readString()
            
            #if DEBUG
            debugPrint("Intro: \(String(describing: readBytes))")
            #endif
            
            try socket.write(from: "USER anonymous\r\n")
            readBytes = try socket.readString()
            
            #if DEBUG
            debugPrint("USER: \(String(describing: readBytes))")
            #endif
            
            try socket.write(from: "PASS anonymous\r\n")
            readBytes = try socket.readString()
            
            #if DEBUG
            debugPrint("PASS: \(String(describing: readBytes))")
            #endif
            
            isAuthenticated = true
            self.runThread = Task {
                if await self.list() {
                    await self.run()
                }
            }
        } catch {
            #if DEBUG
            debugPrint(error.asAFError?.errorDescription ?? "error connecting")
            debugPrint(error.localizedDescription)
            #endif
        }
    }

    private func readFromDataSock() async -> Bool {
        self.data = try! Socket.create()
        try! data.connect(to: socket.remoteHostname, port: Int32(dataPort), timeout: 1000)
        guard let bytes = try? data.readString() else {
            debugPrint("unabled to read from data sock")
            data?.close()
            return false
        }
        let dir = FTPFile.parse(cwd: cwd, testString: bytes)
        data?.close()
        if dir.count <= 1 {
            if dir.count == 1 && dir[0].name == "." {
                debugPrint("Failed... retrying")
                try? await Task.sleep(nanoseconds: self.delay)
                let o = await self.list()
                return o
            } else {
                debugPrint("there is nothing?", dir)
                return false
            }
        } else {
            await MainActor.run {
                self.dir = dir
                delegate?.onList(dirs: dir)
                self.objectWillChange.send()
            }
            return true
        }
    }

    private func write(_ string: String) async -> Bool {
        if socket.isConnected {
            do {
                let (r, w) = try socket.isReadableOrWritable()
                try socket.write(from: string)
                debugPrint("readable: \(r), writable: \(w)")
                return w
            } catch {
                print(error.localizedDescription)
                print(error.asAFError?.errorDescription ?? "something wrong")
                return false
            }
        } else {
            debugPrint("Socket is not connected")
            return false
        }
    }

    private func handled(_ string: String) async -> Bool {
        let split = string.split(separator: " ", maxSplits: 1)
        if(split.count >= 2) {
            let code = Int.init(split[0]) ?? 0, message = split[1]
            print("RESONSE: \(code): \(message)")
            switch code {
            case 150: // Open Stream
                return true
            case 200: // OK
                return true
                
            case 215:
                return true
            case 221:
                //Goodbye
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
                self.readDataThread = Task {
                    await self.readFromDataSock()
                }
                print("\(ip):\(port)")
                return true
            case 250:  // Request file action okay
                return true
            case 257:
                let firstBrace = message.firstIndex(of: #"""#)!
                let lastBrace = message.lastIndex(of: #"""#)!
                await MainActor.run {
                    let path = String(message[firstBrace..<lastBrace])
                    if path.starts(with: #"""#) {
                        self.cwd = String(path[String.Index(encodedOffset: 1)..<String.Index(encodedOffset: path.count)])
                    } else {
                        self.cwd = path
                    }
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

    private func run() async {
        while (socket.isConnected) {
            do {
                if let readAllBytes = try socket.readString() {
                    debugPrint("READ: \(readAllBytes)")
                    await self.handled(readAllBytes)
                }
            } catch {
                debugPrint(error)
                break
            }
        }
    }
    
    private var clients: [Task<(), Never>: Socket] = [:]
    
    private func server(port: Int = 35211) async -> Bool {
        guard let sock = try? Socket.create() else {
            return false
        }
        self.server = sock
        try? self.server .listen(on: port)
        while (sock.isListening) {
            if let client = try? sock.acceptClientConnection() {
                let o = Task {
                    await handleClient(client: client)
                }
                clients[o] = client
            }
        }
        return true
    }
    
    
}



extension FTP {
    
    func upload(filename: URL) async -> Bool {
        return await stor(filename: filename)
    }
    
    
    func download(filename: FTPFile) async -> Bool {
        return await retr(filename: filename.fullPath)
    }
    
    func changeDir(file: FTPFile) async -> Bool {
        if file.directory {
            await cwd(dir: file.name)
            try? await Task.sleep(nanoseconds: 100_000_000)
            await pwd()
            try? await Task.sleep(nanoseconds: 100_000_000)
            await list()
            return true
        }
        return false
    }
    
    func createDir(dir: String) async -> Bool {
        return await mkd(dir: dir)
    }
    
    func getCurrentDir() async -> Bool {
        return await list()
    }
    
    
    func delete(file: FTPFile) async -> Bool {
        var a = false
        if file.directory {
            a = await removeFolder(folder: file.name)
        } else {
            a = await delete(filename: file.name)
        }
        try? await Task.sleep(nanoseconds: 300_000_00)
        let b = await getCurrentDir()
        return a && b
    }
    
    private func removeFolder(folder: String) async -> Bool {
        return await(write("RMD \(folder)"))
    }
    
    
    private func handleClient(client: Socket) async {
        repeat {
            switch action.action {
            case .retrieve:
                let count = try? client.read(into: &action.data)
                debugPrint("Bytes read \(String(describing: count)): \(String(describing: action.data))")
                delegate?.onFileSaved(action: action)
                break
            case .store:
                debugPrint("uploading \(action.name)")
                let written = try? client.write(from: action.data)
                debugPrint("Bytes written & uploaded: \(String(describing: written))")
                break
            case .none:
                
                break
            }
            client.close()
        } while (client.isConnected)
    }
    
    
}

extension FTP {
    
    static var isRunThreadAlive: Bool {
        return shared.runThread != nil && shared.runThread?.isCancelled == false
    }
    
    static func reinitRunThread() {
        if !FTP.isRunThreadAlive {
            debugPrint("Is not running")
            FTP.shared.runThread = Task {
                await FTP.shared.run()
            }
        } else {
            debugPrint("Is running")
        }
    }
    
    static var isConnected: Bool {
        return shared.isConnected
    }
    
    static var ip: String {
        return shared.ip
    }
    
    static var isAuthenticated: Bool {
        return shared.isAuthenticated
    }
    
    static func create(ip: String, port: Int) throws -> FTP {
        let socket = try Socket.create()
        try socket.connect(to: ip, port: .init(port))
        return create(socket: socket)
    }

    static func create(socket: Socket) -> FTP {
        return FTP(socket: socket)
    }
    
    static let shared: FTP = FTP()
    
}

extension FTP {
    

    private func pasv() async-> Bool {
        return await write("PASV\r\n")
    }

    private func port(port: Int) async-> Bool {
        if let string = format(port: port) {
            if self.serverThread == nil {
                self.serverThread = Task {
                    await server(port: port)
                }
            } else {
                self.serverThread?.cancel()
                while self.serverThread?.isCancelled == false {
                    
                }
                self.serverThread = Task {
                    await server(port: port)
                }
            }
            return await write("PORT \(string)\r\n")
        }
        return false
    }

    
    private func list() async -> Bool {
        let a = await pasv()
        let b = await write("LIST\r\n")
        return a && b
    }

    private func cdup() async -> Bool {
        let a = await write("CDUP\r\n")
        let b = await pwd()
        return a && b
    }

    private func mkd(dir: String) async -> Bool {
        let a = await write("MKD \(dir)\r\n")
        let b = await pwd()
        return a && b
    }
    
    private func delete(filename: String) async -> Bool {
        return await write("DELE \(filename)\r\n")
    }

    private func pwd() async -> Bool {
        return await write("PWD\r\n")
    }

    private func cwd(dir: String) async -> Bool {
        return await write("CWD \(dir)\r\n")
    }

    private func noop()async-> Bool {
        return await write("NOOP\r\n")
    }

    private func quit() async -> Bool {
        return await write("QUIT\r\n")
    }

    private func rest(position: Int = 0) async -> Bool {
        return await write("REST \(position)\r\n")
    }

    private func systemType() async -> Bool {
        return await write("SYST")
    }

    private func type(mode: MODE) async -> Bool {
        return await write("TYPE \(mode.rawValue)")
    }

    private func structure() async -> Bool {
        return await write("STRU F")
    }

    private func mode() async -> Bool {
        return await write("MODE S")
    }
    
    private func retr(filename: String) async -> Bool {
        self.action = ActionData(action: .retrieve, name: filename, data: Data())
        if await port(port: serverPort) {
            try? await Task.sleep(nanoseconds: self.delay)
            let b = await write("RETR \(filename)")
            return b
        }
        return false
    }
    
    private func stor(filename: URL) async -> Bool {
        if filename.startAccessingSecurityScopedResource() {
            if let data = try? Data(contentsOf: filename) {
                action = ActionData(action: .store, name: filename.absoluteString, data: data)
                filename.stopAccessingSecurityScopedResource()
                if await port(port: serverPort) {
                    try? await Task.sleep(nanoseconds: self.delay)
                    let b = await write("STOR \(filename.lastPathComponent)")
                    return b
                }
                return false
            }
        }
        return false
    }
}


extension FTP {
    
    private func format(port: Int) -> String? {
        if let addr = SyncServiceImpl.shared.deviceIP {
            let ipParts = addr.split(separator: ".")
            let p1 = (port - (port % 256)) >> 8
            let p2 = port % 256
            return "\(ipParts[0]),\(ipParts[1]),\(ipParts[2]),\(ipParts[3]),\(p1),\(p2)"
        }
        return nil
    }

}
