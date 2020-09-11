//
//  ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//
import CommonMark
import Foundation

#if canImport(UIKit)
import UIKit
public typealias ImageView = UIImageView
public typealias View = UIView
#elseif canImport(AppKit)
import AppKit
public typealias ImageView = NSImageView
public typealias View = NSView
#endif

protocol ViewListConvertible {
  func makeViews(with attributes: [NSAttributedString.Key: Any], imageView: @escaping (URL) -> ImageView) throws -> [View]
}

public final class ViewList {
  
  public init(
    commonmark: String,
    attributes: [NSAttributedString.Key: Any]? = nil,
    imageView: @escaping (URL) -> ImageView) throws
  {
    let document = try CommonMark.Document(commonmark, options: [])
    views = try document.makeViews(with: attributes ?? [:], imageView: imageView)
  }
  
  public let views: [View]
}
