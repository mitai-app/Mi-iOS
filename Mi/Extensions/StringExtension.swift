//
//  StringExtension.swift
//  Mi
//
//  Created by Vonley on 10/8/22.
//

import Foundation


extension String {
    
    func isStringLink(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && string.count > 0) else { return false }
        if detector!.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) > 0 {
            return true
        }
        return false
    }
    
    func verifyUrl () -> Bool {
        return isStringLink(string: self)
    }
}
