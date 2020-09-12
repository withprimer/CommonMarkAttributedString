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
  func makeComponents(with attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent]
}

extension Node: ComponentListConvertible {
  
  func makeComponents(with attributes: [NSAttributedString.Key: Any]) throws -> [CommonMarkComponent] {
    switch self {
    case let image as Image:
      guard let urlString = image.urlString, let url = URL(string: urlString) else {
        return []
      }
      return [.url(url)]
      
    case let container as ContainerOfBlocks:
      guard !container.children.contains(where: { $0 is HTMLBlock }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [.string(htmlString)]
      }
      return try container.children.flatMap { try $0.makeComponents(with: attributes) }
      
    case let container as ContainerOfInlineElements:
      guard !container.children.contains(where: { $0 is RawHTML }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [.string(htmlString)]
      }
      
      let attributedString = try container.children.map { try $0.attributedString(attributes: attributes, attachments: [:]) }.joined()
      return [.string(attributedString)]
      
    default:
      let attributedString = try self.attributedString(attributes: attributes, attachments: [:])
      return [.string(attributedString)]
    }
  }
}
