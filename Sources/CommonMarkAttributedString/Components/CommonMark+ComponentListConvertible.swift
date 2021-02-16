//
//  CommonMark+ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//

import CommonMark
import CoreGraphics
import Foundation

#if canImport(UIKit)
import class UIKit.NSMutableParagraphStyle
import class UIKit.NSTextTab
import class UIKit.NSParagraphStyle
import class UIKit.UIFont
#endif

protocol ComponentListConvertible {
  func makeComponents(with tokenizer: Tokenizer, attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
}

extension Node: ComponentListConvertible {
  
  // MARK: Internal
  
  func makeComponents(with tokenizer: Tokenizer, attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent] {
    switch self {
    case let blockQuote as BlockQuote:
      return try makeBlockQuoteComponents(
        for: blockQuote,
        children: blockQuote.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    case let codeBlock as CodeBlock:
      return try makeCodeBlockComponents(
        for: codeBlock,
        children: codeBlock.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    case let heading as Heading:
      return try makeHeadingComponents(
        for: heading,
        children: heading.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    case let list as List:
      return try makeListComponents(
        for: list,
        children: list.children,
        tokenizer: tokenizer,
        attributes: attributes).joined(separator: "\u{2029}")
    
    case let container as ContainerOfBlocks:
      return try makeBlockContainerComponents(
        for: container,
        children: container.children,
        tokenizer: tokenizer,
        attributes: attributes)
      
    case let container as ContainerOfInlineElements:
      return try makeInlineContainerComponents(
        for: container,
        tokenizer: tokenizer,
        attributes: attributes)
      
    default:
      let simpleComponents = try makeSimpleComponents(attributes: attributes)
      return simpleComponents
        .map { .simple($0) }
        .joined(separator: "\u{2029}")
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
  
  private func makeBlockQuoteComponents(
    for blockQuote: BlockQuote,
    children: [Node],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    let overriddenAttributes = blockQuote.attributes(with: attributes)
    return try makeBlockContainerComponents(
      for: blockQuote,
      children: children,
      tokenizer: tokenizer,
      attributes: overriddenAttributes)
  }
  
  private func makeCodeBlockComponents(
    for codeBlock: CodeBlock,
    children: [Inline & Node],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    let overriddenAttributes = codeBlock.attributes(with: attributes)
    return try makeInlineContainerComponents(
      for: codeBlock,
      tokenizer: tokenizer,
      attributes: overriddenAttributes)
  }
  
  private func makeHeadingComponents(
    for heading: Heading,
    children: [Inline & Node],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    let overriddenAttributes = heading.attributes(with: attributes)
    return try makeInlineContainerComponents(
      for: heading,
      tokenizer: tokenizer,
      attributes: overriddenAttributes)
  }
  
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
    for container: ContainerOfBlocks,
    children: [Node],
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    return try makeBlockContainerComponents(
      for: container.description.unescapedForCommonmark(),
      children: container.children,
      tokenizer: tokenizer,
      attributes: attributes).joined(separator: "\u{2029}")
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
  
  private func makeInlineContainerComponents(
    for container: ContainerOfInlineElements,
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    guard !container.children.contains(where: { $0 is RawHTML }) else {
      let html = try Document(container.description).render(format: .html)
      let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
      return [.simple(.string(htmlString))]
    }
    return try foldedComponents(
      for: container.description.unescapedForCommonmark(),
      children: container.children,
      tokenizer: tokenizer,
      attributes: attributes).joined()
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
    
    return try children
      .reduce(into: [CommonMarkComponent]()) { components, node in
        let nodeComponents = try node.makeComponents(with: tokenizer, attributes: attributes)
        components.append(contentsOf: nodeComponents)
      }
      .reduce(into: [CommonMarkComponent]())  { components, component in
        guard
          case let .simple(.string(lastString)) = components.last,
          case let .simple(.string(newString)) = component
        else {
          components.append(component)
          return
        }
        components.removeLast()
        let foldedString = [lastString, newString].joined()
        components.append(.simple(.string(foldedString)))
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
    
    var itemAttributes = attributes
    
    #if canImport(UIKit)
    if let font = attributes[.font] as? UIFont {
      let indentLocation = font.pointSize
      
      let itemParagraphStyle = NSMutableParagraphStyle()
      itemParagraphStyle.headIndent = indentLocation * 3
      itemParagraphStyle.firstLineHeadIndent = indentation
      
      let tab = NSTextTab(textAlignment: .natural, location: indentLocation * 3, options: [:])
      itemParagraphStyle.tabStops = [tab]
      
      itemAttributes[.paragraphStyle] = itemParagraphStyle
    }
    #endif
    
    let mutableAttributedString = NSMutableAttributedString(string: indentation + delimiter + "\t", attributes: itemAttributes)
    
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
