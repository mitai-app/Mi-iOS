//
//  PSXService.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation
import Alamofire

class PSXService {
    
    func getRequest(url: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        return getRequest(url: url, params: [:], onComplete: onComplete)
    }
    
    func getRequest(url: String, params: [String: [String]], onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let req = AF.request(url, method: .get, parameters: params){ $0.timeoutInterval = 1 }
        req.response { response in
            debugPrint(response)
            onComplete(response)
        }
    }
    
}
