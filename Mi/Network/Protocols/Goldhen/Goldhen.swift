//
//  Goldhen.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation
import Socket

class Goldhen {
    
    func socket() async -> Socket? {
        return await SyncServiceImpl.shared.getSocket(feat: .goldhen)
    }
    
    static let shared = Goldhen()
    
    static func uploadData(data: Data) async -> Bool {
        return await Goldhen.shared.write(string: data)
    }
    
    static func uploadData9020(data: Data) async -> Bool {
        return await Goldhen.shared.write(string: data)
    }
    
    
    private init() {
        
    }
    
    
    func write(string: Data) async -> Bool {
        print("Lets write")
        if let sock = await socket() {
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
    
    func write(string: String) async -> Bool {
        if let socket = await socket() {
            do {
                let bytesWritten = try socket.write(from: string)
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
    
    func read() async -> String? {
        if let socket = await socket() {
            do {
                return try socket.readString()
            } catch {
                print("Unable to read string: \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return nil
    }
}
