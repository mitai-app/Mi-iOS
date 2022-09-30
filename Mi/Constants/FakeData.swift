//
//  FakeData.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import Foundation

let fakeChangeLogs: [Changelog] = [
    Changelog(name: "Mi PS4/PS3 Tool iOS", author: "Mr Smithy x", version: "1.0.0-alpha", contributors: ["Mr Smithy x"], changelog: ["New version"], build: "github.com", changelogs: [
    Changes(name: "1.0.0-alpha", changes: ["Changes"], build: "github")
    ], thanks: ["Jb team"])
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
