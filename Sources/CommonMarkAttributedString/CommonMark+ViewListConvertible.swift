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
import UIKit
typealias Label = UILabel
#elseif canImport(AppKit)
import AppKit

open class NSLabel: NSTextField {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.isBezeled = false
    self.drawsBackground = false
    self.isEditable = false
    self.isSelectable = false
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

typealias Label = NSLabel
#endif

extension Node: ViewListConvertible {
  
  @objc func makeViews(with attributes: [NSAttributedString.Key: Any], imageView: @escaping (URL) -> ImageView) throws -> [View] {
    switch self {
    case let image as Image:
      guard let urlString = image.urlString, let url = URL(string: urlString) else {
        return []
      }
      return [imageView(url)]
    case let container as ContainerOfBlocks:
      guard !container.children.contains(where: { $0 is HTMLBlock }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [makeLabel(with: htmlString)]
      }
      
      return try container.children.flatMap { try $0.makeViews(with: attributes, imageView: imageView) }
    case let container as ContainerOfInlineElements:
      guard !container.children.contains(where: { $0 is RawHTML }) else {
        let html = try Document(container.description).render(format: .html)
        let htmlString = try NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
        return [makeLabel(with: htmlString)]
      }
      
      return try container.children.flatMap { try $0.makeViews(with: attributes, imageView: imageView) }
    default:
      let attributedString = try self.attributedString(attributes: attributes, attachments: [:])
      return [makeLabel(with: attributedString)]
    }
  }
  
  // MARK: - Private
  
  private func makeLabel(with attributedString: NSAttributedString) -> Label {
    let label = Label(frame: .zero)
    #if canImport(UIKit)
      if #available(iOS 10.0, *) {
        label.adjustsFontForContentSizeCategory = true
      }
      label.attributedText = attributedString
      label.numberOfLines = 0
    #elseif canImport(AppKit)
      label.attributedStringValue = attributedString
      if #available(OSX 10.11, *) {
        label.maximumNumberOfLines = 0
      }
    #endif
    return label
  }
}
