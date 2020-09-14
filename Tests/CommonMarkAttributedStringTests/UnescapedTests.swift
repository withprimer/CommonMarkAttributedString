//
//  UnescapedTests.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/15/20.
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

/// All tests here that are testing our own generic extensions are taken from the [official spec](https://spec.commonmark.org/0.29/#backslash-escapes)
final class UnescapedTests: XCTestCase {
  
  func test_fancyLink() throws {
    let rawCommonmark = #"!FancyLink[Wikipedia is cool](Societal Collapse){href="https://en.wikipedia.org/wiki/Societal_collapse"}"#
    let document = try Document(rawCommonmark)
    let commonmark = try document.render(format: .commonmark).unescapedForCommonmark()
    XCTAssertEqual(commonmark, "!FancyLink[Wikipedia is cool](Societal Collapse){href=\"https://en.wikipedia.org/wiki/Societal_collapse\"}\n")
  }
  
//  func test_callout() throws {
//
//  }

//  func test_familyCallout() throws {
//
//  }

//  func test_upload() throws {
//
//  }
  
  // 298: Any ASCII punctuation character may be backslash-escaped
  func test_example298() throws {
    let str = #"\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~"#
    XCTAssertEqual(try str.unescapedForCommonmark(), #"!"\#\$%&'()*+,-./:;<=>?@[\]^_`{|}~"#)
  }
  
  // 299: Backslashes before other characters are treated as literal backslashes
  func test_example299() throws {
    let str = #"\→\A\a\ \3\φ\«"#
    XCTAssertEqual(try str.unescapedForCommonmark(), str)
  }
  
  // 301: If a backslash is itself escaped, the following character is not
  func test_example301() throws {
    let str = #"\\*emphasis*"#
    XCTAssertEqual(try str.unescapedForCommonmark(), #"\*emphasis*"#)
  }
  
  // 304-307: Backslash escapes do not work in code blocks, code spans, autolinks, or raw HTML
  func test_example304() throws {
    let str = #"    \[\]"#
    XCTAssertEqual(try str.unescapedForCommonmark(), #"    \[\]"#)
  }
  
  func test_example305() throws {
    let str = "~~~\n\\[\\]\n~~~"
    XCTAssertEqual(try str.unescapedForCommonmark(), "~~~\n\\[\\]\n~~~")
  }
  
  func test_example306() throws {
    let str = #"<http://example.com?find=\*>"#
    XCTAssertEqual(try str.unescapedForCommonmark(), #"<http://example.com?find=\*>"#)
  }
  
  func test_example307() throws {
    let str = #"<a href="/bar\/)">"#
    XCTAssertEqual(try str.unescapedForCommonmark(), #"<a href="/bar\/)">"#)
  }
  
  // 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
  // 308-310: But they work in all other contexts, including URLs and link titles,
  // link references, and info strings in fenced code blocks:
  //
  // FIXME: Without going into the parser layer, I'm not sure we have enough information
  // to be able to enforce these test cases. We may have to dip into the parser layer.
  func __UNSUPPORTED_test_example308() throws {
    let str = #"[foo](/bar\* "ti\*tle")"#
    XCTAssertThrowsError(try str.unescapedForCommonmark(), #"[foo](/bar* "ti*tle")"#)
  }
  
  func __UNSUPPORTED_test_example309() throws {
    let str = "[foo]\n[foo]: /bar\\* \"ti\\*tle\""
    XCTAssertThrowsError(try str.unescapedForCommonmark(), "[foo]\n[foo]: /bar* \"ti*tle\"")
  }
  
  func __UNSUPPORTED_test_example310() throws {
    let str = "```foo\\+bar\nfoo```"
    XCTAssertThrowsError(try str.unescapedForCommonmark(), "```foo+bar\nfoo```")
  }
  // 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
}
