//
//  PS3MAPI+Structs.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation

struct ps3mapi_response {
    
    let success: Bool
    let response: String
    let code: ps3mapi_code
    
}

struct ConsoleInfo {
    
    let firmware: String
    let type: ConsoleType
    let temp: Temperature
    
}

struct Temperature {
    
    let cpu: String
    let rsx: String
    
    func getCPUFarenheit() -> String {
        return String((Int(cpu) ?? 0) * 9 / 5 + 32)
    }
    
    func getRSXCelcius() -> String {
        return String((Int(rsx) ?? 0) * 9 / 5 + 32)
    }
    
}

extension ps3mapi_response {
    
    static func parse(
        response: String
    ) -> ps3mapi_response {
        return ps3mapi_code.parseResponse(success: true, response: response)
    }

    static func create(
        success: Bool,
        response: String,
        code: ps3mapi_code?
    ) -> ps3mapi_response {
        return ps3mapi_response(success: success, response: response, code: code ?? ps3mapi_code.ps3mapi_error_550())
    }
    
}
