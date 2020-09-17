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
  
  func testTextBeforeInlineExtensionRegex() throws {
    let fancyLink = """
    Some text that comes before the link
    !FancyLink[The Red List](The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\"){href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}
    """
    
    let actual = try Tokenizer().inlineExtension(from: fancyLink)
    let expected = Extension(
      textBefore: "Some text that comes before the link\n",
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
  
  func testTextAfterInlineExtensionRegex() throws {
    let fancyLink = """
    !FancyLink[The Red List](The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\"){href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}
    Some text that comes after the link
    """
    
    let actual = try Tokenizer().inlineExtension(from: fancyLink)
    let expected = Extension(
      textBefore: "",
      textAfter: "\nSome text that comes after the link",
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
  
  func testTextAroundInlineExtensionRegex() throws {
    let fancyLink = """
    Some text that comes before the link
    !FancyLink[The Red List](The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\"){href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}
    Some text that comes after the link
    """
    
    let actual = try Tokenizer().inlineExtension(from: fancyLink)
    let expected = Extension(
      textBefore: "Some text that comes before the link\n",
      textAfter: "\nSome text that comes after the link",
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
  
  func testTextBeforeBlockExtensionRegex() throws {
    let block = """
    Hello world extension incoming
    Extension: Argument\n:::\n[Content]\n:::\n{href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}
    """

    let actual = try Tokenizer().blockExtension(from: block)
    let expected = Extension(
      textBefore: "Hello world extension incoming\n",
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
  
  func testTextAfterBlockExtensionRegex() throws {
    let block = """
    Extension: Argument\n:::\n[Content]\n:::\n{href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}
    Hello world extension came before
    """

    let actual = try Tokenizer().blockExtension(from: block)
    let expected = Extension(
      textBefore: "",
      textAfter: "\nHello world extension came before",
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
  
  func testTextAroundBlockExtensionRegex() throws {
    let block = """
    Hello world extension incoming
    Extension: Argument\n:::\n[Content]\n:::\n{href=\"https://en.wikipedia.org/wiki/Lists_of_IUCN_Red_List_endangered_species\" foo=bar alone}
    Hello world extension came before
    """

    let actual = try Tokenizer().blockExtension(from: block)
    let expected = Extension(
      textBefore: "Hello world extension incoming\n",
      textAfter: "\nHello world extension came before",
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
  
  func testInlineWithNoProperties() throws {
    let fancyLink = "!FancyLink[The Red List](The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\")\nSome text after"
    
    let actual = try Tokenizer().inlineExtension(from: fancyLink)
    let expected = Extension(
      textBefore: "",
      textAfter: "\nSome text after",
      type: .inline,
      name: "FancyLink",
      content: "The Red List",
      argument: "The International Union for Conservation of Nature maintains a \"Red List of Threatened Species\"",
      properties: [:])
    
    XCTAssertEqual(actual, expected)
  }

  func testBlockWithNoProperties() throws {
    let block = "FamilyCallout: Learning Connections\n:::\nIn this project, learners will practice problem solving skills, and gain exposure to physical science concepts. They will:\n- Analyze and test different materials to determine which materials have the properties that are best suited for an intended purpose\n- Conduct an investigation to compare the effects of different forces on the motion of an object\n- Determine if a design solution works as intended to change the speed or direction of an object with a push or pull\n- Practice resourcefulness, by finding ways to use the supplies they have available to solve a given problem\n:::\n\n"
    
    let actual = try Tokenizer().blockExtension(from: block)
    let expected = Extension(
      textBefore: "",
      textAfter: "\n",
      type: .block,
      name: "FamilyCallout",
      content: "In this project, learners will practice problem solving skills, and gain exposure to physical science concepts. They will:\n- Analyze and test different materials to determine which materials have the properties that are best suited for an intended purpose\n- Conduct an investigation to compare the effects of different forces on the motion of an object\n- Determine if a design solution works as intended to change the speed or direction of an object with a push or pull\n- Practice resourcefulness, by finding ways to use the supplies they have available to solve a given problem",
      argument: "Learning Connections",
      properties: [:])

    XCTAssertEqual(actual, expected)
  }
}
