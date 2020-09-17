//
//  Tokenizer.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/14/20.
//

import Foundation

final class Tokenizer {
  
  // MARK: Internal
  
  func blockExtension(from commonmark: String) throws -> Extension? {
    let regularExpression = try RegularExpression.nsRegularExpression(RegularExpression.blockExtensionInText)
    guard let extensionInfo = try extractExtensionInfo(with: regularExpression, from: commonmark, isBlock: true) else {
      return nil
    }
    
    let trimmedContent = try extensionInfo.content.trimmedNewLines()
    return Extension(
      textBefore: extensionInfo.textBefore,
      textAfter: extensionInfo.textAfter,
      type: .block,
      name: extensionInfo.name,
      content: trimmedContent,
      argument: extensionInfo.argument,
      properties: extensionInfo.properties)
  }
  
  func inlineExtension(from commonmark: String) throws -> Extension? {
    let regularExpression = try RegularExpression.nsRegularExpression(RegularExpression.inlineExtensionInText)
    guard let extensionInfo = try extractExtensionInfo(with: regularExpression, from: commonmark, isBlock: false) else {
      return nil
    }
    
    return Extension(
      textBefore: extensionInfo.textBefore,
      textAfter: extensionInfo.textAfter,
      type: .inline,
      name: extensionInfo.name,
      content: extensionInfo.content,
      argument: extensionInfo.argument,
      properties: extensionInfo.properties)
  }
  
  // MARK: Private
  
  private struct ExtensionInfo {
    let textBefore: String
    let textAfter: String
    let name: String
    let content: String
    let argument: String
    let properties: [String: String]
  }
  
  private func extractExtensionInfo(
    with regex: NSRegularExpression,
    from commonmark: String,
    isBlock: Bool) throws -> ExtensionInfo?
  {
    let range = commonmark.utf16Range
    guard let match = regex.firstMatch(in: commonmark, options: [], range: range) else {
      return nil
    }
    
    guard
      match.numberOfRanges == 8,
      let textBeforeRange = Range(match.range(at: 1), in: commonmark),
      let nameRange = Range(match.range(at: 3), in: commonmark),
      let secondRange = Range(match.range(at: 4), in: commonmark),
      let thirdRange = Range(match.range(at: 5), in: commonmark),
      let textAfterRange = Range(match.range(at: 7), in: commonmark)
    else {
      return nil
    }

    let textBefore = commonmark[textBeforeRange]
    let name = commonmark[nameRange]
    let content = isBlock ? commonmark[thirdRange] : commonmark[secondRange]
    let argument = isBlock ? commonmark[secondRange] : commonmark[thirdRange]
    let textAfter = commonmark[textAfterRange]
    let properties: [String: String]
    
    let propertiesRange = match.range(at: 6)
    if propertiesRange.location != NSNotFound, let propertiesStrRange = Range(propertiesRange, in: commonmark) {
      let rawProperties = commonmark[propertiesStrRange]
      properties = try extractProperties(from: String(rawProperties))
    } else {
      properties = [:]
    }
    
    return ExtensionInfo(
      textBefore: String(textBefore),
      textAfter: String(textAfter),
      name: String(name),
      content: String(content),
      argument: String(argument),
      properties: properties)
  }
  
  private func extractProperties(from rawString: String) throws -> [String: String] {
    var properties = [String: String]()
    let mutableRawString = NSMutableString(string: rawString)
    
    // MARK: Key value matching
    
    func processKeyValueMatch(
      _ match: NSTextCheckingResult?,
      flags: NSRegularExpression.MatchingFlags,
      stop: UnsafeMutablePointer<ObjCBool>) -> [String: String]
    {
      var properties = [String: String]()
      guard let match = match, match.numberOfRanges > 2 else {
        return [:]
      }
      
      let rawString = mutableRawString as String
      for valueIndex in stride(from: 2, to: match.numberOfRanges, by: 2) {
        let keyIndex = valueIndex - 1
        let nsKeyRange = match.range(at: keyIndex)
        let nsValueRange = match.range(at: valueIndex)
        if
          let keyRange = Range(nsKeyRange, in: rawString),
          let valueRange = Range(nsValueRange, in: rawString)
        {
          let key = String(rawString[keyRange])
          let value = String(rawString[valueRange])
          properties[key] = value
        }
      }
      
      return properties
    }
    
    // MARK: Lone property matching
    
    func processLonePropertyMatch(
      _ match: NSTextCheckingResult?,
      flags: NSRegularExpression.MatchingFlags,
      stop: UnsafeMutablePointer<ObjCBool>) -> [String: String]
    {
      var properties = [String: String]()
      guard let match = match, match.numberOfRanges > 1 else {
        return [:]
      }
      
      let rawString = mutableRawString as String
      for keyIndex in 1..<match.numberOfRanges {
        let nsKeyRange = match.range(at: keyIndex)
        if let keyRange = Range(nsKeyRange, in: rawString) {
          let key = String(rawString[keyRange])
          properties[key] = ""
        }
      }
      
      return properties
    }
    
    // MARK: Regex processing
    
    let quotedKeyValuePropertiesRegex = try RegularExpression.nsRegularExpression(RegularExpression.keyValueQuotedProperties)
    quotedKeyValuePropertiesRegex.enumerateAndRemove(in: mutableRawString, options: []) { match, flags, stop in
      let newProperties = processKeyValueMatch(match, flags: flags, stop: stop)
      properties.merge(newProperties, uniquingKeysWith: { first, _ in first })
    }
    
    let keyValuePropertiesRegex = try RegularExpression.nsRegularExpression(RegularExpression.keyValueProperties)
    keyValuePropertiesRegex.enumerateAndRemove(in: mutableRawString, options: []) { match, flags, stop in
      let newProperties = processKeyValueMatch(match, flags: flags, stop: stop)
      properties.merge(newProperties, uniquingKeysWith: { first, _ in first })
    }
    
    let lonePropertiesRegex = try RegularExpression.nsRegularExpression(RegularExpression.loneProperties)
    lonePropertiesRegex.enumerateAndRemove(in: mutableRawString, options: []) { match, flags, stop in
      let newProperties = processLonePropertyMatch(match, flags: flags, stop: stop)
      properties.merge(newProperties, uniquingKeysWith: { first, _ in first })
    }
    
    return properties
  }
}

extension String {
  
  func trimmedNewLines() throws -> String {
    let regularExpression = try NSRegularExpression(pattern: #"^[\n\r]+|[\n\r]+$"#, options: [])
    let mutableString = NSMutableString(string: self)
    regularExpression.replaceMatches(in: mutableString, options: [], range: utf16Range, withTemplate: "")
    return mutableString as String
  }
}
