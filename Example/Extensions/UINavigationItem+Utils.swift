//
//  UINavigationItem+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

extension UINavigationItem {
    override open func awakeFromNib() {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        backBarButtonItem = backItem
    }
}
