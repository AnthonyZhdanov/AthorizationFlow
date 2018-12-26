//
//  UIView+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

// MARK: UIView
extension UIView {
    var allSubViews : [UIView] {
        var array = [subviews].flatMap {$0}
        array.forEach { array.append(contentsOf: $0.allSubViews) }
        
        return array
    }
    
    func setBottomShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.masksToBounds = false
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.5
    }
}
