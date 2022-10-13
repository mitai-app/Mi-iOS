//
//  Payload.swift
//  Mi
//
//  Created by Vonley on 10/12/22.
//

import Foundation
import Socket

class Payload {
    
    private init() {}
    
    static func send(addr: String, port: Int32, payload: Data) -> (str: String?, sucess: Bool) {
        do {
            let socket = try Socket.create()
            try socket.connect(to: addr, port: port)
            print("connected to PS4")
            do {
                print("sending payload to PS4")
                try socket.write(from: payload)
                socket.close()
                return ("Sent payload to PS4", true)
            } catch let error {
                return ("Error sending payload to PS4 \(error)", false)
            }
        } catch let error {
            return ("Cannot connect to PS4 \(error)", false)
        }
    }
}

