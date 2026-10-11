//
//  KLogTests.swift
//  MiTests
//
//  Unit tests for the KLog streaming primitives that don't need a console:
//  line reassembly and username parsing.
//

import XCTest
@testable import Mi

final class KLogTests: XCTestCase {

    // MARK: - LineAccumulator

    func testSingleCompleteLine() {
        var acc = LineAccumulator()
        XCTAssertEqual(acc.append("hello\n"), ["hello"])
    }

    func testMultipleLinesInOneChunk() {
        var acc = LineAccumulator()
        XCTAssertEqual(acc.append("a\nb\nc\n"), ["a", "b", "c"])
    }

    func testPartialLineCarriesOverAcrossChunks() {
        var acc = LineAccumulator()
        XCTAssertEqual(acc.append("par"), [])
        XCTAssertEqual(acc.append("tial\nnext"), ["partial"])
        XCTAssertEqual(acc.flush(), "next")
    }

    func testCRLFIsStripped() {
        var acc = LineAccumulator()
        XCTAssertEqual(acc.append("line1\r\nline2\r\n"), ["line1", "line2"])
    }

    func testChunkWithoutNewlineReturnsNothing() {
        var acc = LineAccumulator()
        XCTAssertEqual(acc.append("abc"), [])
        XCTAssertEqual(acc.flush(), "abc")
    }

    func testFlushIsEmptyWhenNothingPending() {
        var acc = LineAccumulator()
        _ = acc.append("done\n")
        XCTAssertNil(acc.flush())
    }

    func testBlankLinesPreserved() {
        var acc = LineAccumulator()
        XCTAssertEqual(acc.append("a\n\nb\n"), ["a", "", "b"])
    }

    // MARK: - KLogParsing

    func testUsernameExtraction() {
        let line = "<118>[SceUserService] User \"Mr-Smithy-x\" (0x10000000) logged in"
        XCTAssertEqual(KLogParsing.quotedValue(in: line), "Mr-Smithy-x")
    }

    func testSingleQuotedValueExtraction() {
        XCTAssertEqual(KLogParsing.quotedValue(in: "title: 'Hello World' done"), "Hello World")
    }

    func testNoQuotesReturnsNil() {
        XCTAssertNil(KLogParsing.quotedValue(in: "no quotes here"))
    }
}
