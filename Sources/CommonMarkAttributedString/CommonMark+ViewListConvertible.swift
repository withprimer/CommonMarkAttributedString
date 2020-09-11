//
//  CommonMark+ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//

#if canImport(UIKit)
import CommonMark
import CoreGraphics
import Foundation
import UIKit

extension Node: ViewListConvertible {
  
  @objc public func makeViews(with attributes: [NSAttributedString.Key: Any], imageView: @escaping (URL) -> UIImageView) throws -> [UIView] {
    switch self {
    case let image as Image:
      guard let urlString = image.urlString, let url = URL(string: urlString) else {
        return []
      }
      return [imageView(url)]
    case let container as ContainerOfBlocks:
      guard !container.children.contains(where: { $0 is HTMLBlock }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes)
        return [makeLabel(with: htmlString)]
      }
      
      return try container.children.flatMap { try $0.makeViews(with: attributes, imageView: imageView) }
    case let container as ContainerOfInlineElements:
      guard !container.children.contains(where: { $0 is RawHTML }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes)
        return [makeLabel(with: htmlString)]
      }
      
      return try container.children.flatMap { try $0.makeViews(with: attributes, imageView: imageView) }
    default:
      let attributedString = try self.attributedString(attributes: attributes, attachments: [:])
      return [makeLabel(with: attributedString)]
    }
  }
  
  // MARK: - Private
  
  private func makeLabel(with attributedString: NSAttributedString?) -> UILabel {
    let label = UILabel()
    if #available(iOS 10.0, *) {
      label.adjustsFontForContentSizeCategory = true
    }
    label.attributedText = attributedString
    label.numberOfLines = 0
    return label
  }
}

#endif
