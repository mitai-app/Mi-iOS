//
//  FTPDelegate.swift
//  Mi
//
//  Created by Vonley on 10/9/22.
//

import Foundation

protocol FTPDelegate {
    func onList(dirs: [FTPFile])
    func onFileSaved (action: ActionData)
}


enum Action {
    case retrieve, store, none
}

struct ActionData {
    let action: Action
    let name: String
    var data: Data
}


enum MODE: String {
    case I = "I", F = "F", S = "S"
}
