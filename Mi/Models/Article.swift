//
//  Article.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import Foundation
import SwiftUI

protocol Article: Decodable {
    var name: String { get  }
    var description: String? { get }
    var icon: String? { get  }
    var link: String? { get  }
    var background: Color? { get }
}

class Constants {
    
    static let ARTICLES = [
        BasicViewType(
            name: "What is Mi?",
            description: "Learn more about what you can do with Mi.",
            icon: "question",
            link: "https://github.com/mitai-app"
        ),
        PayloadViewType(
            name: "Recommended Payload",
            description: "GoldHen, The all-time reccomended payload developed by sistro",
            icon: nil,
            banner: "",
            link: "https://github.com/GoldHen/GoldHen",
            source: "",
            download: [:]
        ),
        BasicViewType(name: "Invite your friend", description: "This bad boy will send payloads to your ps4 and manage your ps3", icon: "help", link: nil),
        ProfileViewType(
            name: "Smithy",
            description: "Learn more about the creator of Mi",
            icon: "money",
            link: "https://twitter.com/MrSmithyx"
        ),
        BasicViewType(
            name: "Special Thanks",
            description: "Specials thanks to the jailbreak scene developers for making this possible.",
            icon: nil,
            link: nil
        ),
        ReadableViewType(
            name: "Support Mi",
            description: "Visit the project page to see how you can support Mi.",
            icon: "team",
            link: "https://ko-fi.com/mrsmithyx",
            author: "Mr Smithy x",
            summary: "We will talk more about this",
            paragraphs: [
                "This is cool"
            ],
            credit: "Mr Smithy x"
        )
    ] as Array<Article>
    
    
}

struct ProfileViewType: Article, Identifiable {
    
    var id: String {
        return UUID().uuidString
    }
    var name: String
    var description: String? = nil
    var icon: String?
    var link: String?
    var background: Color? {
        return Color("quinary")
    }
}

struct PayloadViewType: Article, Identifiable {
    var id: String {
        return UUID().uuidString
    }
    var name: String
    var description: String? = nil
    var icon: String?
    var banner: String
    var link: String?
    var source: String // where is the project located? (in a forum
    var download: [String: String] // downloadable
    var background: Color? {
        
        return Color("quaternary")
    }
}

struct BasicViewType: Article, Identifiable {
    var id: String {
        return UUID().uuidString
    }
    var name: String
    var description: String? = nil
    var icon: String?
    var link: String?
    var background: Color? {
        return Color("tertiary")
    }
}

struct ReadableViewType: Article, Identifiable {
    var id: String {
        return UUID().uuidString
    }
    var name: String
    var description: String? = nil
    var icon: String?
    var link: String?
    let author: String
    let summary: String
    let paragraphs: [String]
    let credit: String
    var background: Color? {
        return Color("purpleDark")
    }
}

enum PS3Version: String, Version {
    
    case V478 = "4.78", V475 = "4.75"
    
    func getVersion() -> String {
        return self.rawValue
    }
    
}

enum PS4Version: String, Version {
    
    func getVersion() -> String {
        return self.rawValue
    }
    
    case V505 = "5.05", V672 = "6.72", V702 = "7.02", V755 = "7.55", V900 = "9.00"
}

protocol Version: Decodable, CodingKey {
    
    func getVersion() -> String
    
}
