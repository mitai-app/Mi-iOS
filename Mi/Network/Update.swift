//
//  Update.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import Foundation
import Alamofire

class Update {
    
    static func getMeta(onComplete: @escaping (Changelog) -> Void) {
        let url = "https://raw.githubusercontent.com/Mr-Smithy-x/Mi/main/meta.json"
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: Changelog.self) { response in
                guard let changelog = response.value else {return}
                onComplete(changelog)
            }
    }
    
}
