//
//  ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//
import CommonMark
import Foundation

public enum CommonMarkComponent: Hashable {
  case `extension`(ExtensionComponent)
  case simple(SimpleCommonMarkComponent)
}

public struct ExtensionComponent: Hashable {
  public let type: ExtensionType
  public let name: String
  public let components: [SimpleCommonMarkComponent]
  public let argument: String
  public let properties: [String: String]
}

public enum SimpleCommonMarkComponent: Hashable {
  case string(NSAttributedString)
  case url(URL)
}

public final class CommonMarkComponentList {
  
  public init(
    commonmark: String,
    attributes: [NSAttributedString.Key: Any]? = nil) throws
  {
    let document = try CommonMark.Document(commonmark, options: [])
    components = try document.makeComponents(with: Tokenizer(), attributes: attributes ?? [:])
  }
  
  public let components: [CommonMarkComponent]
}
