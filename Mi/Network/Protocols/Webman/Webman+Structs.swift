//
//  Webman+Structs.swift
//  Mi
//
//  Created by Vonley on 10/4/22.
//

import Foundation
import SWXMLHash

struct Game: Identifiable {
    var id = UUID()
    
    var title: String
    var link: String
    var icon: String
    var info: String
}

extension Game {
    
    static func parse(ip: String, data: Data) -> [Game] {
        var games: [Game] = []
        let string = String(decoding: data, as: UTF8.self).replacingOccurrences(of: "<>", with: "").replacingOccurrences(of: "</>", with: "")
        
        let xml = XMLHash.config {
            config in
            config.detectParsingErrors = false
            // set any config options here
        }.parse(string)
        for v in xml["X"]["V"].all {
            let id = v.element?.attribute(by: "id")?.text
            if id == "seg_mygames" || id == "seg_wm_dvd_items" {
                continue
            }
            for a in v["A"].all {
                for g in a["T"].all {
                    let key = g.element?.attribute(by: "key")?.text
                    if key == "inc" {
                        continue
                    }
                    //print("ELEMENT1: \(g)")
                    guard let icon = g["P"][0].element?.text
                        else {continue}
                    guard let title = g["P"][1].element?.text else { continue}
                    guard let link = g["P"][2].element?.text
                        else { continue}
                    guard let info = g["P"][3].element?.text
                        else { continue}
                    let game = Game(title: title, link: link, icon: "http://\(ip)\(icon.replacingOccurrences(of: " ", with: "%20"))", info: info)
                    games.append(game)
                }
            }
        }
        //print(" BITCH: \(xml)")
        //print(" SHIT: \(xml["X"]["V"])")
        //print(" SHIT: \(xml["X"]["V"]["A"])")
        debugPrint(games)
        return games
    }
}

