//
//  RPI.swift
//  Mi
//
//  Created by Vonley on 10/15/22.
//

import Foundation


protocol RPI {
    func start(port: Int)
    func hostPackage(payloads: PKG...) -> [String]
    func sendDirectRequest(urls: [String], onSent: @escaping (Data) -> Void, onError: @escaping (Data) -> Void)
    func sendRefPkgUrlRequest(ref_url: String, onSent: @escaping (Data) -> Void, onError: @escaping (Data) -> Void)
}
