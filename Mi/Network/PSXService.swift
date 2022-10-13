//
//  PSXService.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation
import Alamofire
import Socket

class PSXService {
    
    func getRequest(url: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        return getRequest(url: url, params: [:], onComplete: onComplete)
    }
    
    
    func getRequestSync(socket: Socket, path: String) -> String? {
        do {
            try socket.write(from: "GET \(path) HTTP/1.1\r\n\r\n")
            if let result = try socket.readString() {
                socket.close()
                return result
            }
            socket.close()
        } catch {
            socket.close()
        }
        return nil
    }
    

    
    func getRequest(url: String, params: [String: [String]], onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let req = AF.request(url, method: .get, parameters: params){ $0.timeoutInterval = 100 }
        req.validate()
            .response { response in
            onComplete(response)
        }
    }
    
}
