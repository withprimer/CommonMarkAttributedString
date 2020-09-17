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

/// All tests here that are named after examples are taken from the [official spec](https://spec.commonmark.org/0.29/#backslash-escapes)
final class UnescapedTests: XCTestCase {
    
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
  
  func test_ProdFamilyGuide() throws {
    let str = "FamilyCallout: Learning Connections\n:::\nIn this project, learners will practice problem solving skills, and gain exposure to physical science concepts. They will:\n- Analyze and test different materials to determine which materials have the properties that are best suited for an intended purpose\n- Conduct an investigation to compare the effects of different forces on the motion of an object\n- Determine if a design solution works as intended to change the speed or direction of an object with a push or pull\n- Practice resourcefulness, by finding ways to use the supplies they have available to solve a given problem\n:::\n\nFor this project you will invent a device that keeps an egg from cracking when it is dropped from 7 feet high (or higher!).  \n\nHere are the rules you must follow:\n\n- Your device must be dropped with the egg; you can't build anything on the ground for the egg to land on.\n\n- The floor must be hard, like in a kitchen or outside on a sidewalk or thin grass. No dropping it on carpet!\n\n- You must prevent the egg from making a mess if your invention fails. Lay down some trash bags where you drop it to catch any mess you might make.\n\n**To get started, explore your home and look for recyclables or other materials you could use for building your device.** \n\n"

    XCTAssertEqual(try str.unescapedForCommonmark(), "FamilyCallout: Learning Connections\n:::\nIn this project, learners will practice problem solving skills, and gain exposure to physical science concepts. They will:\n- Analyze and test different materials to determine which materials have the properties that are best suited for an intended purpose\n- Conduct an investigation to compare the effects of different forces on the motion of an object\n- Determine if a design solution works as intended to change the speed or direction of an object with a push or pull\n- Practice resourcefulness, by finding ways to use the supplies they have available to solve a given problem\n:::\n\nFor this project you will invent a device that keeps an egg from cracking when it is dropped from 7 feet high (or higher!).  \n\nHere are the rules you must follow:\n\n- Your device must be dropped with the egg; you can't build anything on the ground for the egg to land on.\n\n- The floor must be hard, like in a kitchen or outside on a sidewalk or thin grass. No dropping it on carpet!\n\n- You must prevent the egg from making a mess if your invention fails. Lay down some trash bags where you drop it to catch any mess you might make.\n\n**To get started, explore your home and look for recyclables or other materials you could use for building your device.** \n\n")
  }
}
