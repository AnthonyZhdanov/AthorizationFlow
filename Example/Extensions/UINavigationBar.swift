//
//  UINavigationBar.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

extension UINavigationBar {
    func setGradientBackground() {
        var colors = [UIColor]()
        colors.append(UIColor.colorFrom(hex: "f5515f"))
        colors.append(UIColor.colorFrom(hex: "9f041b"))
        
        var updatedFrame = bounds
        updatedFrame.size.height += frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}
