//
//  LineAccumulator.swift
//  Mi
//

import Foundation

/// Turns arbitrary string chunks from a byte stream into complete lines.
///
/// BlueSocket hands us whatever bytes happen to be available, so a single read
/// may contain several lines, a partial line, or a line split across reads
/// (Android gets this for free from `BufferedReader.readLine()`). `append(_:)`
/// buffers partial content and returns only the lines that are now complete;
/// trailing text with no newline is retained for the next call. A trailing
/// carriage return (`\r\n`) is stripped so CRLF and LF streams look the same.
struct LineAccumulator {

    private var buffer = ""

    /// Feeds a chunk and returns any newly completed lines (newline stripped).
    mutating func append(_ chunk: String) -> [String] {
        buffer += chunk
        // Split at the Unicode-scalar level: Swift treats "\r\n" as a single
        // grapheme, so String.contains("\n") / split(separator:) would miss the
        // LF inside a CRLF pair.
        guard buffer.unicodeScalars.contains("\n") else { return [] }
        var lines: [String] = []
        var current = String.UnicodeScalarView()
        for scalar in buffer.unicodeScalars {
            if scalar == "\n" {
                lines.append(Self.trimCR(String(current)))
                current = String.UnicodeScalarView()
            } else {
                current.append(scalar)
            }
        }
        // Whatever follows the last newline is an incomplete line — keep it.
        buffer = String(current)
        return lines
    }

    /// Returns and clears any buffered partial line (e.g. when the stream
    /// closes without a trailing newline). `nil` when nothing is pending.
    mutating func flush() -> String? {
        guard !buffer.isEmpty else { return nil }
        let remaining = Self.trimCR(buffer)
        buffer = ""
        return remaining.isEmpty ? nil : remaining
    }

    private static func trimCR(_ line: String) -> String {
        line.hasSuffix("\r") ? String(line.dropLast()) : line
    }
}

/// Lightweight parsing helpers for KLog lines.
enum KLogParsing {

    /// Extracts the first quoted token from a log line — e.g. the PSN user name
    /// in `[SceUserService] User "Name" (0x...) logged in`. Mirrors the Android
    /// regex in `test/KLogRegexText.kt`. Returns the text without its quotes.
    static func quotedValue(in line: String) -> String? {
        // A single- or double-quoted token, honouring backslash escapes.
        let pattern = "([\"'])(?:\\\\.|[^\\\\])*?\\1"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range),
              let matchRange = Range(match.range, in: line) else { return nil }
        let token = line[matchRange]            // includes the surrounding quotes
        guard token.count >= 2 else { return nil }
        return String(token.dropFirst().dropLast())
    }
}
