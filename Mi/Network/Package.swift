//
//  Update.swift
//  Mi
//
//  Created by Vonley on 9/29/22.
//

import Foundation
import Alamofire

struct PackageResponse: Decodable, Identifiable {
    var id: String {
        return title
    }
    let title: String // title name
    let author: String // author of repo
    let banner: String
    let description: String
    let packages: [PackageModel]
}

struct PackageModel: Decodable, Identifiable {
    var id: String {
        return name
    }
    let name: String
    let author: String
    let version: String
    let type: PackageType
    let icon: String
    let link: String
    let dl: [String: String]
    
}

enum PackageType: String, Decodable, CodingKey {
    case app = "app", tool = "tool", plugin = "plugin"
}

class Package {
    
    static func getMeta(onComplete: @escaping (Changelog) -> Void) {
        let url = "https://raw.githubusercontent.com/Mr-Smithy-x/Mi/main/meta.json"
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: Changelog.self) { response in
                guard let changelog = response.value else {return}
                onComplete(changelog)
            }
    }
    
    static func findRepo(
        url: String,
        onComplete: @escaping (PackageResponse) -> Void,
        onError: @escaping (String) -> Void
    ) {
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: PackageResponse.self) { response in
            guard let changelog = response.value else {
                onError("Invalid repo")
                return
            }
            onComplete(changelog)
        }
    }
    
    static func searchBin(search: String, onComplete: @escaping (PackageResponse) -> Void) {
        let url = "https://raw.githubusercontent.com/mitai-app/versioning/main/packages.json"
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: PackageResponse.self) { response in
                guard let changelog = response.value else {return}
                onComplete(changelog)
            }
    }
    
}
