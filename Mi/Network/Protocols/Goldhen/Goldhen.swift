//
//  Goldhen.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation
import Socket

class Goldhen {
    
    var socket: Socket? {
        return SyncServiceImpl.shared.getSocket(feat: .goldhen())
    }
    
    static let shared = Goldhen()
    
    static func uploadData(data: Data) -> Bool {
        return Goldhen.shared.write(string: data)
    }
    
    static func uploadData9020(data: Data) -> Bool {
        return Goldhen.shared.write(string: data)
    }
    
    
    private init() {
        
    }
    
    
    func write(string: Data) -> Bool {
        print("Lets write")
        if let sock = socket {
            print("Socket is not nil")
            do {
                let bytesWritten = try sock.write(from: string)
                print("Bytes: Written: \(bytesWritten)")
                sock.close()
                return bytesWritten > 0
            } catch {
                print("Unable to write string:  \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return false
    }
    
    func write(string: String) -> Bool {
        if socket != nil {
            do {
                let bytesWritten = try socket!.write(from: string)
                print("Bytes: Written: \(bytesWritten)")
                return bytesWritten > 0
            } catch {
                print("Unable to write string: \(string) - \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return false
    }
    
    func read() -> String? {
        if socket != nil {
            do {
                return try socket!.readString()
            } catch {
                print("Unable to read string: \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return nil
    }
}
