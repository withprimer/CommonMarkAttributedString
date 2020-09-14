//
//  InlineExtension.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/14/20.
//

import Foundation

public enum ExtensionType: Hashable {
  case block
  case inline
}

public struct Extension: Hashable {
  public let type: ExtensionType
  public let name: String
  public let content: String
  public let argument: String
  public let properties: [String: String]
}
