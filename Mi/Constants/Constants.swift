//
//  Constants.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import Foundation
import SwiftUI



let grads: [LinearGradient] = [
LinearGradient(
    gradient: Gradient(
        stops: [
            .init(
                color: Color("blueSlate"),
                location: 0
            ),
            .init(
                color: Color("purple"),
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
