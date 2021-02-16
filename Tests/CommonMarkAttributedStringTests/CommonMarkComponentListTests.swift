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
  
  func testHeaderAndLinkComponents() throws {
    let commonmark = """
    # Header
    !FancyLink[Wikipedia is cool](Societal Collapse){href=\"https://en.wikipedia.org/wiki/Societal_collapse\"}
    """

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

    XCTAssertEqual(components.count, 2)
    
    if case .simple(.string(let str)) = components.first {
      XCTAssertEqual(str.string, "Header")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }
    
    if case .extension(let ext) = components.dropFirst().first {
      XCTAssertEqual(ext.type, .inline)
    } else {
      XCTFail("Expected .extension with a type of .block to be the second component in \(components)")
    }
  }
    
  func testTextAndInlineExtensionComponents() throws {
    let commonmark = """
    Some text beforehand!
    !FancyLink[Wikipedia is cool](Societal Collapse){href=\"https://en.wikipedia.org/wiki/Societal_collapse\"}
    Testing test **test**
    ### HELLO
    """

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

    XCTAssertEqual(components.count, 3)

    if case .simple(.string(let str)) = components.first {
      XCTAssertEqual(str.string, "Some text beforehand!")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }

    if case .extension(let ext) = components.dropFirst().first {
      XCTAssertEqual(ext.type, .inline)
    } else {
      XCTFail("Expected .extension with a type of .inline to be the second component in \(components)")
    }
    
    if case .simple(.string(let str)) = components.dropFirst(2).first {
      XCTAssertEqual(str.string, "Testing test test\u{2029}HELLO")
    } else {
      XCTFail("Expected .simple(.string)) to be the third component")
    }
  }
  
  func testTextAndBlockExtensionComponents() throws {
    let commonmark = """
    Testing test **test**
    Some text beforehand!
    Extension: Argument
    :::
    [Content]
    :::
    {href=\"https://www.withprimer.com\" bar=foo hellooo}
    And some text after!
    ### HELLO WORLD BIG HEADER
    """

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

    XCTAssertEqual(components.count, 3)

    if case .simple(.string(let str)) = components.first {
      XCTAssertEqual(str.string, "Testing test test Some text beforehand!")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }

    if case .extension(let ext) = components.dropFirst().first {
      XCTAssertEqual(ext.type, .block)
    } else {
      XCTFail("Expected .extension with a type of .block to be the second component in \(components)")
    }
    
    if case .simple(.string(let str)) = components.dropFirst(2).first {
      XCTAssertEqual(str.string, "And some text after!\u{2029}HELLO WORLD BIG HEADER")
    } else {
      XCTFail("Expected .simple(.string)) to be the third component")
    }
  }
  
  func testBlockWithNoPropertiesAndTextAfter() throws {
    let commonmark = "FamilyCallout: Learning Connections\n:::\nIn this project, learners will practice problem solving skills, and gain exposure to physical science concepts. They will:\n- Analyze and test different materials to determine which materials have the properties that are best suited for an intended purpose\n- Conduct an investigation to compare the effects of different forces on the motion of an object\n- Determine if a design solution works as intended to change the speed or direction of an object with a push or pull\n- Practice resourcefulness, by finding ways to use the supplies they have available to solve a given problem\n:::\n\nFor this project you will invent a device that keeps an egg from cracking when it is dropped from 7 feet high (or higher!).  \n\nHere are the rules you must follow:\n\n- Your device must be dropped with the egg; you can't build anything on the ground for the egg to land on.\n\n- The floor must be hard, like in a kitchen or outside on a sidewalk or thin grass. No dropping it on carpet!\n\n- You must prevent the egg from making a mess if your invention fails. Lay down some trash bags where you drop it to catch any mess you might make.\n\n**To get started, explore your home and look for recyclables or other materials you could use for building your device.** \n\n"
    
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

    XCTAssertEqual(components.count, 2)
    
    if case .extension(let ext) = components.first {
      XCTAssertEqual(ext.type, .block)
      XCTAssertEqual(ext.components.count, 1)
    } else {
      XCTFail("Expected .extension with a type of .block to be the first component in \(components)")
    }
    
    if case .simple(.string(let str)) = components.dropFirst().first {
      XCTAssertEqual(str.string, "For this project you will invent a device that keeps an egg from cracking when it is dropped from 7 feet high (or higher!).\u{2029}Here are the rules you must follow:\u{2029}\t• Your device must be dropped with the egg; you can't build anything on the ground for the egg to land on.\u{2029}\t• The floor must be hard, like in a kitchen or outside on a sidewalk or thin grass. No dropping it on carpet!\u{2029}\t• You must prevent the egg from making a mess if your invention fails. Lay down some trash bags where you drop it to catch any mess you might make.\u{2029}To get started, explore your home and look for recyclables or other materials you could use for building your device.")
    } else {
      XCTFail("Expected .simple(.string)) to be the second component")
    }
  }
  
  func testPreserveStandardList() throws {
    let commonmark = """
    1. Cut a piece of paper into a 1.5\" x 11\" strip.
    1. Roll it around your straw and tape it in three places to hold it's shape. The straw shown here is a paper straw made using the instructions in a prior step of this project.
    """

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
      XCTAssertEqual(str.string, "\t1. Cut a piece of paper into a 1.5\" x 11\" strip.\u{2029}\t2. Roll it around your straw and tape it in three places to hold it's shape. The straw shown here is a paper straw made using the instructions in a prior step of this project.")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }
  }
  
  func testListItemWithImage() throws {
    let commonmark = """
    1. Cut a piece of paper into a 1.5\" x 11\" strip.
    ![](https://res.cloudinary.com/primer-cloudinary/image/upload/v1599788011/upg8sag6kgtpt8vqos1s.png)
    1. Roll it around your straw and tape it in three places to hold it's shape. The straw shown here is a paper straw made using the instructions in a prior step of this project.
    ![](https://res.cloudinary.com/primer-cloudinary/image/upload/v1599788024/wbgdryijgfagcyqscl2b.png)
    """

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

    XCTAssertEqual(components.count, 4)

    if case .simple(.string(let str)) = components.first {
      XCTAssertEqual(str.string, "\t1. Cut a piece of paper into a 1.5\" x 11\" strip. ")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }

    if case .simple(.url(let url)) = components.dropFirst().first {
      XCTAssertEqual(url.absoluteString, "https://res.cloudinary.com/primer-cloudinary/image/upload/v1599788011/upg8sag6kgtpt8vqos1s.png")
    } else {
      XCTFail("Expected .simple(.url) to be the second component in \(components)")
    }

    if case .simple(.string(let str)) = components.dropFirst(2).first {
      XCTAssertEqual(str.string, "\t2. Roll it around your straw and tape it in three places to hold it's shape. The straw shown here is a paper straw made using the instructions in a prior step of this project. ")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }

    if case .simple(.url(let url)) = components.dropFirst(3).first {
      XCTAssertEqual(url.absoluteString, "https://res.cloudinary.com/primer-cloudinary/image/upload/v1599788024/wbgdryijgfagcyqscl2b.png")
    } else {
      XCTFail("Expected .simple(.url) to be the second component in \(components)")
    }
  }
  
  func testListItemImageOnly() throws {
    let commonmark = """
    1. ![](https://res.cloudinary.com/primer-cloudinary/image/upload/v1599788011/upg8sag6kgtpt8vqos1s.png)
    1. Roll it around your straw
    """

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

    XCTAssertEqual(components.count, 3)

    if case .simple(.string(let str)) = components.first {
      XCTAssertEqual(str.string, "\t1. ")
    } else {
      XCTFail("Expected .simple(.string)) to be the first component")
    }

    if case .simple(.url(let url)) = components.dropFirst().first {
      XCTAssertEqual(url.absoluteString, "https://res.cloudinary.com/primer-cloudinary/image/upload/v1599788011/upg8sag6kgtpt8vqos1s.png")
    } else {
      XCTFail("Expected .simple(.url) to be the second component in \(components)")
    }

    if case .simple(.string(let str)) = components.dropFirst(2).first {
      XCTAssertEqual(str.string, "\t2. Roll it around your straw")
    } else {
      XCTFail("Expected .simple(.string)) to be the third component")
    }
  }

  func testPreservesNewlinesWithCorrectSeparator() throws {
    let commonmark = """
    For this project you will invent a device that keeps an egg from cracking when it is dropped from 7 feet high (or higher!).

    Here are the rules you must follow:

    - Your device must be dropped with the egg; you can\'t build anything on the ground for the egg to land on.
    
    - The floor must be hard, like in a kitchen or outside on a sidewalk or thin grass. No dropping it on carpet!

    - You must prevent the egg from making a mess if your invention fails. Lay down some trash bags where you drop it to catch any mess you might make.

    **To get started, explore your home and look for recyclables or other materials you could use for building your device.**
    """
    
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
  }
  
  func testHeadingSizeAttributes() throws {
    let commonmark = """
    # Header
    This is some additional text below the header.
    """
    
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
      let headerAttributes = str.attributes(at: 0, effectiveRange: nil)
      #if canImport(UIKit)
      let headerFont = headerAttributes[.font] as! UIFont
      XCTAssertEqual(headerFont.pointSize, 48)
      #elseif canImport(AppKit)
      let headerFont = headerAttributes[.font] as! NSFont
      XCTAssertEqual(headerFont.pointSize, 48)
      #endif
    } else {
      XCTFail("Expected .string to be the first component in \(components)")
    }
  }
}
