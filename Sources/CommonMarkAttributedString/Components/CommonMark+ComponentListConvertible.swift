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
      guard !container.children.contains(where: { $0 is HTMLBlock }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [.simple(.string(htmlString))]
      }
      return try container.children.flatMap { try $0.makeComponents(with: tokenizer, attributes: attributes) }
      
    case let container as ContainerOfInlineElements:
      guard !container.children.contains(where: { $0 is RawHTML }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [.simple(.string(htmlString))]
      }
      return try foldedInlineComponents(for: container, tokenizer: tokenizer, attributes: attributes)
      
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
  
  /// "Folds" the children elements into their `NSAttributedString`s when applicable, breaking them apart when images or extensions are encountered
  private func foldedInlineComponents(
    for container: ContainerOfInlineElements,
    tokenizer: Tokenizer,
    attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
  {
    if let blockExtension = try tokenizer.blockExtension(from: container.description.unescapedForCommonmark()) {
      let textBeforeComponent: CommonMarkComponent?
      if !blockExtension.textBefore.isEmpty {
        let string = try Document(blockExtension.textBefore).attributedString(attributes: attributes, attachments: [:])
        textBeforeComponent = .simple(.string(string))
      } else {
        textBeforeComponent = nil
      }
      
      let contentComponents = try Document(blockExtension.content).makeSimpleComponents(attributes: attributes)
      let component = ExtensionComponent(
        type: .block,
        name: blockExtension.name,
        components: contentComponents,
        argument: blockExtension.argument,
        properties: blockExtension.properties)
      
      let textAfterComponent: CommonMarkComponent?
      if !blockExtension.textAfter.isEmpty {
        let string = try Document(blockExtension.textAfter).attributedString(attributes: attributes, attachments: [:])
        textAfterComponent = .simple(.string(string))
      } else {
        textAfterComponent = nil
      }
      
      return [
        textBeforeComponent,
        .extension(component),
        textAfterComponent,
      ].compactMap { $0 }
    }
    
    if let inlineExtension = try tokenizer.inlineExtension(from: container.description.unescapedForCommonmark()) {
      let textBeforeComponent: CommonMarkComponent?
      if !inlineExtension.textBefore.isEmpty {
        let string = try Document(inlineExtension.textBefore).attributedString(attributes: attributes, attachments: [:])
        textBeforeComponent = .simple(.string(string))
      } else {
        textBeforeComponent = nil
      }
      
      let contentComponents = try Document(inlineExtension.content).makeSimpleComponents(attributes: attributes)
      let component = ExtensionComponent(
        type: .inline,
        name: inlineExtension.name,
        components: contentComponents,
        argument: inlineExtension.argument,
        properties: inlineExtension.properties)
      
      let textAfterComponent: CommonMarkComponent?
      if !inlineExtension.textAfter.isEmpty {
        let string = try Document(inlineExtension.textAfter).attributedString(attributes: attributes, attachments: [:])
        textAfterComponent = .simple(.string(string))
      } else {
        textAfterComponent = nil
      }
      
      return [
        textBeforeComponent,
        .extension(component),
        textAfterComponent,
      ].compactMap { $0 }
    }
    
    return try container.children.reduce(into: [CommonMarkComponent]()) { components, node in
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
}
