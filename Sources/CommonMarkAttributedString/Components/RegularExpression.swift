//
//  RegularExpression.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/14/20.
//

import Foundation

// MARK: - RegularExpression

/// An enum representing a regular expression used to parse a generic extension
///
/// Future me and future team: I'm sorry. I grabbed this from
/// [remark/generic-extensions](https://github.com/medfreeman/remark-generic-extensions/blob/f39c678280501ef09737e0e9443be31d083ad30e/src/utils/regexes.js),
/// which is what the web uses to parse out generic extensions. When we inevitably rewrite this to move away
/// from using regexes, just know that you have my unwavering support and my deepest condolences. Godspeed my friend.
enum RegularExpression {
  static let inlineExtension = #"!(\w+)(?:\[([^\]]*)\])?(?:\(([^)]*)\))?(?:\{([^}]*)\})?"#
  static let blockExtension = "^\(blockExtensionWithoutBeginningOfWord)"
  
  static let keyValueQuotedProperties = #"(?:\t )*([^\t />"'=]+)=(?:"([^"]+)")"#
  static let keyValueProperties = #"(?:\t )*([^\t />"'=]+)=([^\t />"'=]+)"#
  static let loneProperties = #"(?:\t )*([^\t />"'=]+)"#
  
  static var inlineExtensionInText: String {
    return "^(.*?)(\(RegularExpression.inlineExtension))(.*?)$"
  }
  
  static var blockExtensionInText: String {
    return "^(.*?)(\(blockExtensionWithoutBeginningOfWord))(.*?)$"
  }
  
  static func nsRegularExpression(_ pattern: String) throws -> NSRegularExpression {
    try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
  }
  
  // MARK: Private
  
  private static var blockExtensionWithoutBeginningOfWord = #"(\w+):(?:(?:[ \t]+)([^\f\n\r\v]*))?(?:[\f\n\r\v]+):::(.*?):::(?:(?:[\f\n\r\v]+)(?:\{([^}]*)\}))?"#
}

// MARK: - NSRegularExpression

extension NSRegularExpression {
  
  func enumerateAndRemove(
    in mutableString: NSMutableString,
    options: MatchingOptions,
    using block: @escaping (NSTextCheckingResult?, MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
  {
    let string = mutableString as String
    enumerateMatches(in: string, options: options, range: string.utf16Range, using: block)
    replaceMatches(in: mutableString, options: options, range: string.utf16Range, withTemplate: "")
  }
}
