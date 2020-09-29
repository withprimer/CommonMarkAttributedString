//
//  Components+Joined.swift
//  CommonMarkAttributedString
//
//  Created by Gonzalo Nunez on 9/29/20.
//

#if canImport(AppKit)
import class AppKit.NSAttributedString
import class AppKit.NSMutableAttributedString
#elseif canImport(UIKit)
import class UIKit.NSAttributedString
import class UIKit.NSMutableAttributedString
#endif

extension Array where Element == CommonMarkComponent {
  
  func joined(separator: String? = nil) -> [CommonMarkComponent] {
    guard let first = first else { return [] }
    guard count > 1 else { return [first] }
    
    return suffix(from: startIndex.advanced(by: 1)).reduce(into: [first]) { components, component in
      switch component {
      case .extension(let extensionComponent):
        let joinedExtension = ExtensionComponent(
          type: extensionComponent.type,
          name: extensionComponent.name,
          components: extensionComponent.components.joined(),
          argument: extensionComponent.argument,
          properties: extensionComponent.properties)
        components.append(.extension(joinedExtension))
      case .simple(let simpleComponent):
        switch simpleComponent {
        case .string(let attributedString):
          switch components.last {
          case .simple(.string(let existingAttributedString))?:
            components.removeLast()
            let newString = [existingAttributedString, attributedString].joined(separator: separator)
            components.append(.simple(.string(newString)))
          default:
            components.append(.simple(.string(attributedString)))
          }
        case .url(let url):
          components.append(.simple(.url(url)))
        }
      }
    }
  }
}
