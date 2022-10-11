//
//  Constants.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import Foundation
import SwiftUI


class Constants {
    
    static var goldhen: Data? = nil
    static let TITLE = "Mi - JB Host"
    static let BODY = "Mi"
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


let grads: [LinearGradient] = [
    LinearGradient(
        gradient: Gradient(
            stops: [
                .init(
                    color: Color("tertiary"),
                    location: 0
                ),
                .init(
                    color: Color("quinary"),
                    location: 1
                )
            ]
        ),
        startPoint: UnitPoint(
            x: 0.5002249700310126,
            y: 3.0834283490377423e-7),
        endPoint: UnitPoint(
            x: -0.0016390833199537713,
            y: 0.977085239704672)),
LinearGradient(
    gradient: Gradient(
        stops: [
            .init(
                color: Color("quinary"),
                location: 0
            ),
            .init(
                color: Color("quinary"),
                location: 1
            )
        ]
    ),
    startPoint: UnitPoint(
        x: 0.5002249700310126,
        y: 3.0834283490377423e-7),
    endPoint: UnitPoint(
        x: -0.0016390833199537713,
        y: 0.977085239704672)),


LinearGradient(
    gradient: Gradient(
        stops: [
            .init(
                color: Color("pink"),
                location: 0
            ),
            .init(
                color: Color("blueSlate"),
                location: 1
            )
        ]
    ),
    startPoint: UnitPoint(
        x: 0.5002249700310126,
        y: 3.0834283490377423e-7),
    endPoint: UnitPoint(
        x: -0.0016390833199537713,
        y: 0.977085239704672)),



LinearGradient(
    gradient: Gradient(
        stops: [
            .init(
                color: Color("mintAccent"),
                location: 0
            ),
            .init(
                color: Color("blueSlate"),
                location: 1
            )
        ]
    ),
    startPoint: UnitPoint(
        x: 0.5002249700310126,
        y: 3.0834283490377423e-7),
    endPoint: UnitPoint(
        x: -0.0016390833199537713,
        y: 0.977085239704672))
]
