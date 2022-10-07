//
//  Webman+Enums.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import Foundation
import SwiftUI


enum BootModes: String {
    case reboot = "",
    softboot = "?soft",
    hardboot = "?hard",
    quickboot = "?quick",
    vsh = "?vsh"
}

enum WebmanCommands: String {
    
    case refresh = "/refresh.ps3",
    reloadxmb = "/reloadxmb.ps3",
    restart = "/restart.ps3", //?0 scan
    reboot = "/reboot.ps3",//?soft, ?hard, ?quick, ?vsh
    shutdown = "/shutdown.ps3",
    quit = "/quit.ps3",
    play = "/play.ps3",
    mount = "/mount.ps3",
    fixgame = "/fixgame.ps3",
    insert = "/insert.ps3",
    eject = "/eject.ps3",
    xmb = "/xmb.ps3", //$eject, $insert, $exit, $reload,
    screenshot = "/xmb.ps3$screenshot?show", //?fast - shows its smaller
    screenshot_fast = "/xmb.ps3$screenshot?show?fast", //?fast - shows its smaller
    notify = "/popup.ps3",
    beep = "/beep.ps3?",
    unmount = "/mount.ps3/unmount"
    
}

enum GameType: CaseIterable {
    case ps3, psp, ps2, psx, query
}


extension WebmanCommands: Identifiable {
    var id: Self { self }
    
    var iconName: String {
        switch self {
            
        case .refresh:
            return "arrow.triangle.2.circlepath.circle"
        case .reloadxmb:
            return "arrow.clockwise.circle"
        case .restart:
            return "restart.circle"
        case .reboot:
            return "togglepower"
        case .shutdown:
            return "power.circle"
        case .quit:
            return "xmark.circle"
        case .xmb:
            return "arrow.down.right.and.arrow.up.left.circle"
        case .play:
            return "opticaldisc"
        case .fixgame:
            return "opticaldisc"
        case .eject:
            return "eject.circle"
        case .insert:
            return "opticaldisc"
        case .mount:
            return "opticaldisc"
        case .screenshot:
            return "sparkles.tv"
        case .screenshot_fast:
            return "sparkles.tv"
        case .notify:
            return "paperplane"
        case .beep:
            return "speaker.wave.2.circle"
        case .unmount:
            return "eject.circle"
        }
    }
    
    var title: String {
        return getTitle()
    }
    
    var color: Color {
        return Color("quarnary")
    }
    
    
    func getTitle() -> String {
        switch(self) {
        case .refresh:
            return "Refresh Modules"
        case .reloadxmb:
            return "Reload XMB"
        case .restart:
            return "Restart Console"
        case .reboot:
            return "Reboot Console"
        case .shutdown:
            return "Shutdown Console"
        case .quit:
            return "Quit to XMB"
        case .play:
            return "Play Game"
        case .mount:
            return "Mount Game"
        case .fixgame:
            return "Fix Game"
        case .insert:
            return "Insert Disc"
        case .eject:
            return "Eject Disc"
        case .xmb:
            return "XMB"
        case .screenshot:
            return "Screenshot"
        case .screenshot_fast:
            return "Screenshot (compressed)"
        case .notify:
            return "Notify Console"
        case .beep:
            return "Buzz"
        case .unmount:
            return "Unmount Game"
        }
    }
}
