//
//  StringExtension.swift
//  Mi
//
//  Created by Vonley on 10/8/22.
//

import Foundation


extension String {
    
    func strip() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
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
    
    func asRegex(option: NSRegularExpression.Options = .anchorsMatchLines) -> NSRegularExpression {
        return try! NSRegularExpression(
            pattern: self, options: option
        )
    }
    
    func matches(regex: NSRegularExpression) -> [NSTextCheckingResult] {
        let stringRange = NSRange(location: 0, length:self.utf16.count)
        return regex.matches(in: self, range: stringRange)
    }
}

extension Array where Element == NSTextCheckingResult {
    func find(testString: String) -> [[String]] {
        var result: [[String]] = []
        for match in self {
            var groups: [String] = []
            for rangeIndex in 1 ..< match.numberOfRanges {
                let nsRange = match.range(at: rangeIndex)
                guard !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) else { continue }
                let string = (testString as NSString).substring(with: nsRange)
                groups.append(string)
            }
            if !groups.isEmpty {
                result.append(groups)
            }
        }
        return result
    }
}
