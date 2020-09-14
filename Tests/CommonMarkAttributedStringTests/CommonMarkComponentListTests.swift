//
//  CommonMarkComponentListTests.swift
//  CommonMark
//
//  Created by Gonzalo Nunez on 9/14/20.
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

final class CommonMarkComponentListTests: XCTestCase {
  
  func testSingleStringComponent() throws {
    let commonmark = "A *bold* way to add __emphasis__ to your `code`"
    
    #if canImport(UIKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 24.0),
        .foregroundColor: UIColor.systemBlue
    ]
    #elseif canImport(AppKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24.0),
        .foregroundColor: NSColor.systemBlue
    ]
    #endif
    
    let components = try CommonMarkComponentList(
      commonmark: commonmark,
      attributes: attributes).components
    
    XCTAssertEqual(components.count, 1)
    if case .simple(.string(let str)) = components.first {
      XCTAssertEqual(str.string, "A bold way to add emphasis to your code")
    } else {
      XCTFail("Expected .string to be the first component in \(components)")
    }
  }
  
  func testSingleURLComponent() throws {
    let commonmark = "![Youtube Video](https://www.youtube.com/watch?v=oHg5SJYRHA0)"
    
    #if canImport(UIKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 24.0),
        .foregroundColor: UIColor.systemBlue
    ]
    #elseif canImport(AppKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24.0),
        .foregroundColor: NSColor.systemBlue
    ]
    #endif
    
    let components = try CommonMarkComponentList(
      commonmark: commonmark,
      attributes: attributes).components
    
    XCTAssertEqual(components.count, 1)
    if case .simple(.url(let url)) = components.first {
      XCTAssertEqual(url.absoluteString, "https://www.youtube.com/watch?v=oHg5SJYRHA0")
    } else {
      XCTFail("Expected .url to be the first component in \(components)")
    }
  }
  
  func testSingleInlineExtensionComponent() throws {
    let commonmark = "!FancyLink[Wikipedia is cool](Societal Collapse){href=\"https://en.wikipedia.org/wiki/Societal_collapse\"}"

    #if canImport(UIKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 24.0),
        .foregroundColor: UIColor.systemBlue
    ]
    #elseif canImport(AppKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24.0),
        .foregroundColor: NSColor.systemBlue
    ]
    #endif

    let components = try CommonMarkComponentList(
      commonmark: commonmark,
      attributes: attributes).components

    XCTAssertEqual(components.count, 1)
    if case .extension(let ext) = components.first {
      XCTAssertEqual(ext.type, .inline)
      XCTAssertEqual(ext.name, "FancyLink")
      XCTAssertEqual(ext.components.count, 1)
      XCTAssertEqual(ext.argument, "Societal Collapse")
      XCTAssertEqual(ext.properties, ["href": "https://en.wikipedia.org/wiki/Societal_collapse"])
    } else {
      XCTFail("Expected .extension with a type of .inline to be the first component in \(components)")
    }
  }
  
  func testSingleBlockExtensionComponent() throws {
    let commonmark = "Extension: Argument\n:::\n[Content]\n:::\n{foo=\"bar and stuff\" class}"

    #if canImport(UIKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 24.0),
        .foregroundColor: UIColor.systemBlue
    ]
    #elseif canImport(AppKit)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24.0),
        .foregroundColor: NSColor.systemBlue
    ]
    #endif

    let components = try CommonMarkComponentList(
      commonmark: commonmark,
      attributes: attributes).components

    XCTAssertEqual(components.count, 1)
    if case .extension(let ext) = components.first {
      XCTAssertEqual(ext.type, .block)
      XCTAssertEqual(ext.name, "Extension")
      XCTAssertEqual(ext.components.count, 1)
      XCTAssertEqual(ext.argument, "Argument")
      XCTAssertEqual(ext.properties, ["foo": "bar and stuff", "class": ""])
    } else {
      XCTFail("Expected .extension with a type of .block to be the first component in \(components)")
    }
  }
}
