//
//  TokenizerTests.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/14/20.
//

import Foundation
import XCTest

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@testable import CommonMarkAttributedString

final class TokenizerTests: XCTestCase {
  
  func testSingleInlineExtensionRegex() throws {
    let fancyLink = "!FancyLink[The Red List](The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\"){href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}"
    
    let actual = try Tokenizer().inlineExtension(from: fancyLink)
    let expected = Extension(
      textBefore: "",
      textAfter: "",
      type: .inline,
      name: "FancyLink",
      content: "The Red List",
      argument: "The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\"",
      properties: [
        "href": "https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species",
        "foo": "bar",
        "alone": "",
      ])
    
    XCTAssertEqual(actual, expected)
  }
  
  func testSingleBlockExtensionRegex() throws {
    let block = "Extension: Argument\n:::\n[Content]\n:::\n{href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}"

    let actual = try Tokenizer().blockExtension(from: block)
    let expected = Extension(
      textBefore: "",
      textAfter: "",
      type: .block,
      name: "Extension",
      content: "[Content]",
      argument: "Argument",
      properties: [
        "href": "https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species",
        "foo": "bar",
        "alone": "",
      ])

    XCTAssertEqual(actual, expected)
  }
}
