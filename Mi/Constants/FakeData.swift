//
//  FakeData.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import Foundation

let fakeChangeLogs: [Changelog] = [
    Changelog(title: "Initial Release", summary: "This is the first release", version: "1.0.0", released: Date()),
    Changelog(title: "Alpha Release", summary: "This is the first alpha release", version: "0.9.0", released: Date()),
    Changelog(title: "Pre-Alpha Release", summary: "This is the first pre-alpha release", version: "0.1.0", released: Date())
]

let fakeConsoles = [
    Console(ip: "192.168.11.45", name: "PS4", wifi: "Gaoooub", type: .ps4()),
    Console(ip: "192.168.11.46", name: "PS3", wifi: "Gaoooub", type: .ps3()),
    Console(ip: "192.168.11.54", name: "Google Home", wifi: "Gaoooub", type: .unknown()),
    Console(ip: "192.168.11.185", name: "Macbook", wifi: "Gaoooub", type: .unknown())
]

let fakeGames = [
    Game(title: "Grand Theft Auto VI", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto V", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto IV", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto Vice City Stories", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto Liberty City Stories", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto San Andreas", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto Vice City", link: "", icon: "", info: ""),
    Game(title: "Grand Theft Auto III", link: "", icon: "", info: ""),
]
