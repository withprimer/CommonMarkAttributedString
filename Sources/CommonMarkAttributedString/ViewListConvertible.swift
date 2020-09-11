//
//  ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//

#if canImport(UIKit)
import CommonMark
import Foundation
import UIKit

protocol ViewListConvertible {
  func makeViews(with attributes: [NSAttributedString.Key: Any], imageView: @escaping (URL) -> UIImageView) throws -> [UIView]
}

public final class ViewList {
  
  public init(
    commonmark: String,
    attributes: [NSAttributedString.Key: Any]? = nil,
    imageView: @escaping (URL) -> UIImageView) throws
  {
    let document = try CommonMark.Document(commonmark, options: [])
    views = try document.makeViews(with: attributes ?? [:], imageView: imageView)
  }
  
  public let views: [UIView]
}
#endif
