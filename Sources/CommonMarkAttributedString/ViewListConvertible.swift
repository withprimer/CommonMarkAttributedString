//
//  ViewListConvertible.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/11/20.
//

#if canImport(UIKit)
import Foundation
import UIKit

public protocol ViewListConvertible {
  func makeViews(with attributes: [NSAttributedString.Key: Any], imageView: @escaping (URL) -> UIImageView) throws -> [UIView]
}
#endif
