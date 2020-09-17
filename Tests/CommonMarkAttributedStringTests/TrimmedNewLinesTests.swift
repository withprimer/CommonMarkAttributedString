//
//  TrimmedNewLinesTests.swift
//  CommonMarkAttributedStringTests
//
//  Created by Gonzalo Nunez on 9/17/20.
//

import CommonMark
import Foundation
import XCTest

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@testable import CommonMarkAttributedString

final class TrimmedNewLinesTests: XCTestCase {
  
  func testNoNewLines() throws {
    let str = "hello world"
    XCTAssertEqual(try str.trimmedNewLines(), "hello world")
  }
  
  func testPrefixNewLine() throws {
    let str = "\nhello world"
    XCTAssertEqual(try str.trimmedNewLines(), "hello world")
  }
  
  func testSuffixNewLine() throws {
    let str = "hello world\n"
    XCTAssertEqual(try str.trimmedNewLines(), "hello world")
  }
  
  func testSurroundedNewLines() throws {
    let str = "\nhello world\n"
    XCTAssertEqual(try str.trimmedNewLines(), "hello world")
  }
  
  func testSurroundedMultipleNewLines() throws {
    let str = "\n\n\nhello world\n\n"
    XCTAssertEqual(try str.trimmedNewLines(), "hello world")
  }
}
