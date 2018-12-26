//
//  NSAttributedString+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

extension NSMutableAttributedString {
    class func AttributedStringOf(size: CGFloat, text: String, color: UIColor) -> NSMutableAttributedString {
        let titleMutableString = NSMutableAttributedString(string: text as String, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: size, weight: .medium)])
        titleMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        
        return titleMutableString
    }
}
