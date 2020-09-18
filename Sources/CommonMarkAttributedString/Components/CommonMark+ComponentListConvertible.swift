//
//  CommonMark+ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//

import CommonMark
import CoreGraphics
import Foundation

protocol ComponentListConvertible {
  func makeComponents(with tokenizer: Tokenizer, attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
}

extension Node: ComponentListConvertible {
  
  // MARK: Internal
  
  func makeComponents(with tokenizer: Tokenizer, attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent] {
    switch self {
    case let container as ContainerOfBlocks:
      return try makeBlockContainerComponents(
        for: container.description.unescapedForCommonmark(),
        children: container.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    case let list as List:
      return try makeListComponents(
        for: list,
        children: list.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    case let container as ContainerOfInlineElements:
      guard !container.children.contains(where: { $0 is RawHTML }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [.simple(.string(htmlString))]
      }
      return try foldedComponents(
        for: container.description.unescapedForCommonmark(),
        children: container.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    default:
      let simpleComponents = try makeSimpleComponents(attributes: attributes)
      return simpleComponents.map { .simple($0) }
    }
  }
  
  func makeSimpleComponents(attributes: [NSAttributedString.Key: Any]) throws -> [SimpleCommonMarkComponent] {
    switch self {
    case let image as Image:
      guard let urlString = image.urlString, let url = URL(string: urlString) else {
        return []
      }
      return [.url(url)]
    default:
      let attributedString = try self.attributedString(attributes: attributes, attachments: [:])
      return [.string(attributedString)]
    }
  }
  
  // MARK: Private
  
  private func makeListComponents(
    for list: List,
    children: [List.Item],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    return try children.enumerated().flatMap { offset, child -> [CommonMarkComponent] in
      try child.makeListItemComponents(
        in: list,
        for: child,
        at: offset,
        with: tokenizer,
        attributes: attributes)
    }
  }
  
  private func makeBlockContainerComponents(
    for containerString: String,
    children: [Node],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    guard !children.contains(where: { $0 is HTMLBlock }) else {
      let html = try Document(containerString).render(format: .html)
      let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
      return [.simple(.string(htmlString))]
    }
    
    let blockExtensionComponents = try parseExtension(
      str: containerString,
      attributes: attributes,
      tokenizer: tokenizer,
      type: .block,
      with: tokenizer.blockExtension(from:))
    
    if !blockExtensionComponents.isEmpty {
      return blockExtensionComponents
    }
    
    return try children.flatMap { try $0.makeComponents(with: tokenizer, attributes: attributes) }
  }
  
  /// "Folds" the child elements into their `NSAttributedString`s when applicable, breaking them apart when images or extensions are encountered
  private func foldedComponents(
    for containerString: String,
    children: [Node],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    let blockExtensionComponents = try parseExtension(
      str: containerString,
      attributes: attributes,
      tokenizer: tokenizer,
      type: .block,
      with: tokenizer.blockExtension(from:))
    
    if !blockExtensionComponents.isEmpty {
      return blockExtensionComponents
    }
    
    let inlineExtensionComponents = try parseExtension(
      str: containerString,
      attributes: attributes,
      tokenizer: tokenizer,
      type: .inline,
      with: tokenizer.inlineExtension(from:))
    
    if !inlineExtensionComponents.isEmpty {
      return inlineExtensionComponents
    }
    
    return try children.reduce(into: [CommonMarkComponent]()) { components, node in
      switch node {
      case is Image:
        let imageComps = try node.makeComponents(with: tokenizer, attributes: attributes)
        components.append(contentsOf: imageComps)
      default:
        let attributedString = try node.attributedString(attributes: attributes, attachments: [:])
        switch components.last {
        case .simple(.string(let existingAttributedString))?:
          components.removeLast()
          let newString = [existingAttributedString, attributedString].joined()
          components.append(.simple(.string(newString)))
        default:
          components.append(.simple(.string(attributedString)))
        }
      }
    }
  }
  
  private func parseExtension(
    str: String,
    attributes: [NSAttributedString.Key: Any],
    tokenizer: Tokenizer,
    type: ExtensionType,
    with parse: (String) throws -> Extension?) throws -> [CommonMarkComponent]
  {
    guard let extensionInfo = try parse(str) else {
      return []
    }
    
    let textBeforeComponents: [CommonMarkComponent]
    if !extensionInfo.textBefore.isEmpty {
      let components = try Document(extensionInfo.textBefore).makeComponents(with: tokenizer, attributes: attributes)
      textBeforeComponents = components
    } else {
      textBeforeComponents = []
    }
    
    let contentComponents = try Document(extensionInfo.content).makeComponents(with: tokenizer, attributes: attributes)
    let component = ExtensionComponent(
      type: type,
      name: extensionInfo.name,
      components: contentComponents,
      argument: extensionInfo.argument,
      properties: extensionInfo.properties)
    
    let textAfterComponents: [CommonMarkComponent]
    if !extensionInfo.textAfter.isEmpty {
      let components = try Document(extensionInfo.textAfter).makeComponents(with: tokenizer, attributes: attributes)
      textAfterComponents = components
    } else {
      textAfterComponents = []
    }
    
    return textBeforeComponents + [.extension(component)] + textAfterComponents
  }
  
  private func makeListItemComponents(
    in list: List,
    for item: List.Item,
    at position: Int,
    with tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    var components = try item.children.flatMap { try $0.makeComponents(with: tokenizer, attributes: attributes) }
    guard !components.isEmpty else {
      return components
    }
    
    let delimiter = list.delimiter(at: position)
    let indentation = String(repeating: "\t", count: list.nestingLevel)
    let mutableAttributedString = NSMutableAttributedString(string: indentation + delimiter + " ", attributes: attributes)
    
    let originalFirst = components.removeFirst()
    switch originalFirst {
    case .extension, .simple(.url):
      components.insert(originalFirst, at: 0)
      components.insert(.simple(.string(mutableAttributedString)), at: 0)
      return components
    case .simple(.string(let str)):
      mutableAttributedString.append(str)
      components.insert(.simple(.string(mutableAttributedString)), at: 0)
    }
    
    return components
  }
}
