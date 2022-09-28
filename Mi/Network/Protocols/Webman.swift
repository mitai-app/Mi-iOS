//
//  Webman.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation
import Alamofire

class WebMan: NSObject {

    static let shared = WebMan()
    var service: PSXService!
    
    private func buildGameURL(targetIp: String) -> String {
        return "http://\(targetIp)/dev_hdd0/xmlhost/game_plugin/mygames.xml"
    }
    
    var depth: Int = 0
    
    var depthIndent: String {
        return [String](repeating: "  ", count: self.depth).joined()
    }
    
    
    private override init() {
        super.init()
        self.service = PSXServiceImpl()
    }
    
    static func getGames(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = shared.buildGameURL(targetIp: ip)
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func notify(ip: String, message: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.notify.rawValue)/\(message.replacingOccurrences(of: " ", with: "20%"))"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func beep(ip: String, code: Int = 1, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.beep.rawValue)\(code)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func reboot(ip: String, boot: BootModes, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.reboot.rawValue)\(boot.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func shutdown(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.shutdown.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func refresh(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.refresh.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func play(ip: String, game: Game, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(game.link)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func insert(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.insert.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func eject(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.eject.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func unmount(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.unmount.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func screenshot(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.screenshot.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func exit(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.xmb.rawValue)$exit"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func reloadGame(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(Commands.xmb.rawValue)$reloadgame"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    enum BootModes: String {
        case reboot = "",
        softboot = "?soft",
        hardboot = "?hard",
        quickboot = "?quick",
        vsh = "?vsh"
    }
    
    
    enum Commands: String {
        
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
    
    
}


extension WebMan.Commands: Identifiable {
    var id: Self { self }
    
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
