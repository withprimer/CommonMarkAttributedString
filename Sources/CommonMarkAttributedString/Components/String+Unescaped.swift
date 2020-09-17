//
//  String+Unescaped.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/15/20.
//

import CommonMark
import Foundation

extension String {
  
  /// Removes backslash escapes from strings behind a given set of characters that CommonMark escapes with
  /// backslashes after processing. In other words, it "undoes" the escaping rules outlined in the CommonMark spec.
  ///
  /// - Parameters:
  ///   - node: The `Node` that the string belongs to. Used to determine whether or not CommonMark escapes backslashes in that node or its children.
  ///
  /// By the time we go to parse generic extensions, CommonMark has already processed those nodes
  /// and as a result it has [escaped all ascii punctuation](https://spec.commonmark.org/0.29/#backslash-escapes).
  /// As a result, we want to be dealing with the literal strings by the time we go to try and match them
  /// to our regular expressions.
  ///
  /// - Important: There are three **UNSUPPORTED** cases, 308-310, please see UnescapedTests.swift.
  func unescapedForCommonmark() throws -> String {
    var didEscapeBackslash = false
    var result = ""
    var idx = index(startIndex, offsetBy: 1)
    
    let removingNewLines = self.replacingOccurrences(of: "\n", with: "") // Remove all newlines so that we can search the Document by index
    let document = try Document(removingNewLines)
    
    while idx < endIndex {
      let prev = index(before: idx)
      let prevChar = self[prev]
      let currentChar = self[idx]
      
      defer {
        didEscapeBackslash = prevChar.isBacklash && currentChar.isBacklash
        idx = index(idx, offsetBy: 1)
      }
      
      let utf16Offset = idx.utf16Offset(in: self)
      let allowsBackslashEscapes = try document.allowsBackslashEscapes(at: utf16Offset)
      if allowsBackslashEscapes && prevChar.isBacklash && currentChar.isEscapedByCommonmark && !didEscapeBackslash {
        if currentChar.isBacklash {
          result.append(prevChar)
        }
      } else if !didEscapeBackslash {
        result.append(prevChar)
      }
      
      if idx == index(endIndex, offsetBy: -1) {
        result.append(currentChar)
      }
    }
    return result
  }
}

private extension Character {
  
  var isBacklash: Bool {
    self == #"\"#
  }
  
  var isEscapedByCommonmark: Bool {
    isASCII &&
    (isPunctuation || isMathSymbol || self == Character("`"))
  }
}

private extension Document {
  
  func allowsBackslashEscapes(at position: Int) throws -> Bool {
    // When a document is guaranteed to be one line, column == index (except column is one-based)
    let childForPosition = allChildren()
      .reversed() // Reverse so that we get the deepest child
      .first(where: { child in
        child.range.lowerBound.column-1...child.range.upperBound.column-1 ~= position
      })
    
    guard let child = childForPosition else {
      return true
    }
  
    switch child {
    case is CodeBlock, is Code, is Link, is HTMLBlock, is RawHTML:
      return false
    default:
      return true
    }
  }
}

private extension ContainerOfBlocks {
  
  func allChildren() -> [Node] {
    children.flatMap { child -> [Node] in
      switch child {
      case let container as ContainerOfBlocks:
        return [container] + container.allChildren()
      case let container as ContainerOfInlineElements:
        return [container] + container.children
      default:
        return [child]
      }
    }
  }
}
