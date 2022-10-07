//
//  Webman.swift
//  Mi
//
//  Created by Vonley on 9/23/22.
//

import Foundation
import Alamofire
import SwiftUI

class Webman: NSObject {

    static let shared = Webman()
    var service: PSXService!
    
    private func buildGameURL(targetIp: String) -> String {
        return "http://\(targetIp)/dev_hdd0/xmlhost/game_plugin/mygames.xml"
    }
    
    private override init() {
        super.init()
        self.service = PSXService()
    }
    
    static func getGames(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = shared.buildGameURL(targetIp: ip)
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func notify(ip: String, message: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.notify.rawValue)/\(message.replacingOccurrences(of: " ", with: "20%"))"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func beep(ip: String, code: Int = 1, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.beep.rawValue)\(code)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func buildScreenshotURL(ip: String) -> String {
        return "http://\(ip)\(WebmanCommands.screenshot.rawValue)"
    }
    
    
    static func reboot(ip: String, boot: BootModes, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.reboot.rawValue)\(boot.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func shutdown(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.shutdown.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    
    static func refresh(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.refresh.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func play(ip: String, game: Game, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(game.link)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func insert(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.insert.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func eject(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.eject.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func unmount(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.unmount.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func screenshot(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.screenshot.rawValue)"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func exit(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.xmb.rawValue)$exit"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
    static func reloadGame(ip: String, onComplete: @escaping (AFDataResponse<Data?>) -> Void) {
        let url = "http://\(ip)\(WebmanCommands.xmb.rawValue)$reloadgame"
        shared.service.getRequest(url: url, onComplete: onComplete)
    }
    
}
