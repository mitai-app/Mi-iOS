//
//  FTPFile.swift
//  Mi
//
//  Created by Vonley on 10/9/22.
//

import Foundation

struct FTPFile: Identifiable {
    
    var id: String {
        return "\(cwd)-\(name)"
    }
    
    var fullPath: String {
        let path = "\(cwd)/\(name)"
        if path.starts(with: "\"") {
            print("fixing: \(path) to \(path.substring(from: String.Index(encodedOffset: 1)))")
            return path.substring(from: String.Index(encodedOffset: 1))
        }
        return path
    }
    
    let cwd: String
    let directory: Bool
    let permissions: String
    let nbfiles: Int
    let owner: String
    let group: String
    let size: Int
    let date: String
    let name: String
}

extension FTPFile {
    
    
    static func parse(cwd: String, testString: String) -> [FTPFile] {
        let patterns = #"^([\-ld])([\-rwxs]{9})\s+(\d+)\s+(.+)\s+(.+)\s+(\d+)\s+(\w{3}\s+\d{1,2}\s+(?:\d{1,2}:\d{1,2}|\d{4}))\s+(.+)$"#
        let pattern =  #"^([\-ld])([\-rwxs]{9})\s+(\d+)\s+(\w+)\s+(\w+)\s+(\d+)\s+(\w{3}\s+\d{1,2}\s+(?:\d{1,2}:\d{1,2}|\d{4}))\s+(.+)$"#
        let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        let stringRange = NSRange(location: 0, length: testString.utf16.count)
        let matches = regex.matches(in: testString, range: stringRange)
        var result: [[String]] = []
        for match in matches {
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
        var index = 0
        let res: [FTPFile] = result.map { array in
            
            let directory: Bool = array[0] == "d"
            let permisions: String = array[1]
            let nbfiles: Int = Int(array[2]) ?? 0
            let owner: String = array[3]
            let group: String = array[4]
            let size: Int = Int(array[5]) ?? 0
            let date: String = array[6]
            let name: String = array[7]
            let file = FTPFile(
                cwd: cwd,
                directory: directory,
                permissions:permisions,
                nbfiles: nbfiles,
                owner: owner,
                group: group,
                size: size,
                date: date,
                name: name
            )
            index += 1
            return file
        }
        debugPrint(res)
        return res.sorted { file1, file2 in
            if (file1.directory && file2.directory) {
                return file1.name.compare(file2.name) == ComparisonResult.orderedAscending
            } else if file1.directory {
                return true
            } else if file2.directory {
                return false
            } else {
                return false
            }
        }
    }
}
