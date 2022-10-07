//
//  FTP.swift
//  Mi
//
//  Created by Vonley on 10/6/22.
//

import Foundation

import Socket

struct FTPFile {
    
}

class FTP: ObservableObject {


    private var socket: Socket!
    private var data: Socket!
    private var dataPort: Int = 0
    private var res: ((String) -> Void)!

    private var parseRegex = "^([\\-ld])([\\-rwxs]{9})\\s+(\\d+)\\s+(.+)\\s+(.+)\\s+(\\d+)\\s+(\\w{3}\\s+\\d{1,2}\\s+(?:\\d{1,2}:\\d{1,2}|\\d{4}))\\s+(.+)\\$"
    var dir: [FTPFile] = []
        private(set)
    
    var cwd: String = "\\"

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
        } catch {
            
        }
    }

    func readLis() {
        /*data = Socket()
        data.connect(InetSocketAddress(socket.inetAddress.hostAddress, dataPort))
        println("LETS GO")
        data.getInputStream().use { input ->
            val readAllBytes = input.readBytes()
            FileOutputStream("file.txt").use {
                it.write(readAllBytes)
                it.flush()
            }
            val input1 = readAllBytes.decodeToString()
            this.dir = FTPHelper.parseListCommand(input1)
            dir.map {
                "${cwd}/${it.name} - Is DIR: ${it.directory}"
            }.forEach(::println)
        }
        data.close()
        println("Closed")*/

    }

    func write(_ string: String) -> Bool {
        do {
            try socket.write(from: string)
            return true
        } catch {
            return false
        }
    }

    func handled(_ string: String) -> Bool {
        let split = string.split(separator: " ", maxSplits: 2)
        if(split.count >= 2) {
            let code = Int.init(split[0]) ?? 0, message = split[1]
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
                let firstBrace = message.firstIndex(of: "(")!
                let lastBrace = message.firstIndex(of: ")")!
                let ipPort = String(message[firstBrace..<lastBrace])
                let parts = ipPort.split(separator: ",")
                let ip = "\(parts[0]).\(parts[1]).\(parts[2]).\(parts[3])"
                let port = (Int.init(parts[4]) ?? 0) * 256 + (Int.init(parts[5]) ?? 0)
                self.dataPort = port
                //Thread(readList).start()
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


    func run() {
        print("READING")
        while (socket.isConnected) {
            do {
                print("Connected: ${socket.isConnected}")
                let readAllBytes = try socket.readString()!

                print("READ: \(readAllBytes)")
                self.handled(readAllBytes)
            }catch {
                
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
        return write("LIST\r\n")
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
