//
//  UIImageView+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView {
    func setGradientBackground() {
        var colors = [UIColor]()
        colors.append(UIColor.colorFrom(hex: "f5515f"))
        colors.append(UIColor.colorFrom(hex: "9f041b"))
        
        var updatedFrame = bounds
        updatedFrame.size.height += frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        image = gradientLayer.createGradientImage()
    }
    
    func setCardShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.masksToBounds = false
        layer.shadowRadius = 7.0
        layer.shadowOpacity = 0.7
        layer.cornerRadius = self.frame.width / 10
    }
}
