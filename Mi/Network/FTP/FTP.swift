//
//  FTP.swift
//  Mi
//
//  Created by Vonley on 10/6/22.
//

import Foundation
import Socket

struct FTPFile: Identifiable {
    
    var id: Int
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
    
    
    static func parse(testString: String) -> [FTPFile] {
        let pattern = #"^([\-ld])([\-rwxs]{9})\s+(\d+)\s+(.+)\s+(.+)\s+(\d+)\s+(\w{3}\s+\d{1,2}\s+(?:\d{1,2}:\d{1,2}|\d{4}))\s+(.+)$"#
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
                id: index,
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
        return res
    }
}

protocol FTPDelegate {
    func onList(dirs: [FTPFile])
}

class FTP: ObservableObject {


    private var socket: Socket!
    private var data: Socket!
    private var dataPort: Int = 0
    private var res: ((String) -> Void)!
    
    var delegate: FTPDelegate?
    
    @Published var dir: [FTPFile] = []
    
    @Published var cwd: String = "\\"

    init(socket: Socket, res: @escaping (String) -> Void) {
        self.socket = socket
        self.res = res
        self.auth()
    }

    func auth() {
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
        print("LETS GO")
        guard let bytes = try! data.readString() else {
            data.close()
            return
        }
        await MainActor.run {
            print(bytes)
            self.dir = FTPFile.parse(testString: bytes)
            delegate?.onList(dirs: dir)
            data.close()
            print("Closed")
        }

    }

    func write(_ string: String) -> Bool {
        do {
            try socket.write(from: string)
            return true
        } catch {
            print(error)
            return false
        }
    }

    func handled(_ string: String) -> Bool {
        let split = string.split(separator: " ", maxSplits: 1)
        if(split.count >= 2) {
            let code = Int.init(split[0]) ?? 0, message = split[1]
            print(code)
            print(message)
            switch code {
            case 150:
                print(message)
                return true
            case 200:
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
                self.cwd = String(message[firstBrace..<lastBrace])
                return true
            case 502:
                print(message)
                return true
            default:
                print("Not Handled - $code: $message")
                return false
                break
            }
        }
        return false

    }


    func run() async {
        print("READING")
        while (socket.isConnected) {
            do {
                print("Connected: \(socket.isConnected)")
                let readAllBytes = try socket.readString()!

                print("READ: \(readAllBytes)")
                self.handled(readAllBytes)
            }catch {
                print(error)
            }
        }
    }
    
    
    static func create(ip: String, port: Int, res: @escaping (String) -> Void) throws -> FTP {
        let socket = try Socket.create()
        try socket.connect(to: ip, port: .init(port))
        return create(socket: socket, res: res)
    }
    

    static func create(socket: Socket, res: @escaping (String) -> Void) -> FTP {
        return FTP(socket: socket, res: res)
    }
    
}

extension FTP {
    

    func pasv()-> Bool {
        return write("PASV\r\n")
    }

    func list()-> Bool {
        return pasv() && write("LIST\r\n")
    }

    func delete(filename: String)-> Bool {
        return write("DELE $filename\r\n")
    }

    func pwd()-> Bool {
        return write("PWD\r\n")
    }

    func cwd(dir: String)-> Bool {
        return write("CWD $dir\r\n")
    }

    func cdup()-> Bool {
        return write("CDUP\r\n") && pwd()
    }

    func mkd(dir: String)-> Bool {
        return write("MKD $dir\r\n") && pwd()
    }

    func noop()-> Bool {
        return write("NOOP\r\n")
    }

    func quit()-> Bool {
        return write("QUIT\r\n")
    }

    func rest(position: Int = 0)-> Bool {
        return write("REST $position\r\n")
    }

    func systemType() -> Bool {
        return write("SYST")
    }

    enum MODE {
        case I, F, S
    }

    func type(mode: MODE) -> Bool {
        return write("TYPE ${mode.name}")
    }

    func structure() -> Bool {
        return write("STRU F")
    }

    func mode() -> Bool {
        return write("MODE S")
    }

    func stor(filename: String)-> Bool {
        return write("STOR $filename")
    }
}
