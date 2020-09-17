//
//  String+UTF16Range.swift
//  CommonMark
//
//  Created by Gonzalo Nunez on 9/14/20.
//

import Foundation

extension String {
  
  var utf16Range: NSRange {
    NSRange(location: 0, length: utf16.count)
  }
}
