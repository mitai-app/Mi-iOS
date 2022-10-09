//
//  File.swift
//  Mi
//
//  Created by Vonley on 10/9/22.
//

import Foundation
import Socket

func handleGetRequest(typeOfRequest: String, headers: [String: String], content: String) {
    
}

func handlePostRequest(typeOfRequest:String, headers: [String: String], content: String) {
    
}

func handleWebClient(client: Socket) {
    do {
        while(client.isConnected) {
            if let str = try? client.readString() {
                let content = str.components(separatedBy: "\r\n\r\n")
                let headers = content[0].components(separatedBy: "\r\n")
                var typeOfRequest: String = ""
                var o: [String: String] = [:]
                headers.forEach({ str in
                    let split = str.split(separator: ":")
                    if split.count > 1 {
                        o[String(describing: split[0])] =  String(describing: split[1])
                    } else {
                        typeOfRequest = String(describing: split[0])
                    }
                })
                
                debugPrint(typeOfRequest)
                debugPrint(o)
                debugPrint(content[1])
                if typeOfRequest.starts(with: "GET") {
                    try? client.write(from: "Hello\r\n")
                    client.close()
                    handleGetRequest(typeOfRequest: typeOfRequest, headers: o, content: content[1])
                } else if typeOfRequest.starts(with: "POST") {
                    try? client.write(from: "Hello\r\n")
                    client.close()
                    handlePostRequest(typeOfRequest: typeOfRequest, headers: o, content: content[1])
                }
            } else {
                
            }
        }
    } catch {
        debugPrint(error.localizedDescription)
    }
}

func ok () {
    do {
        let socket = try Socket.create()
        try socket.listen(on: 29999)
        while (socket.isListening) {
            if let client = try? socket.acceptClientConnection() {
                let o = Task {
                    await handleWebClient(client: client)
                }
                //clients[o] = client
            }
        }
    } catch {
        
    }
}
