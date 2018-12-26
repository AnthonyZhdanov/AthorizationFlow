//
//  HintTextField.swift
//  Example
//
//  Created by Anton Zhdanov on 21.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Material

@IBDesignable
final class HintTextField: TextField, Validatable {
    
    @IBInspectable var regex: String = ""
    @IBInspectable var validationMessage: String = ""
    @IBInspectable var isDark = false {
        didSet {
            setupColors()
        }
    }
    
    private func setupColors() {
        self.font = UIFont.systemFont(ofSize: 16)
        let whiteAlpha = UIColor.init(white: 1, alpha: 0.5)
        
        self.dividerActiveColor = isDark ? UIColor.lightGray : whiteAlpha
        self.dividerNormalColor = isDark ? UIColor.lightGray : whiteAlpha
        self.placeholderNormalColor = isDark ? UIColor.gray : whiteAlpha
        self.placeholderActiveColor = isDark ? UIColor.gray : whiteAlpha
        self.detailColor = isDark ? UIColor.red : UIColor.darkGray
        self.textColor = isDark ? UIColor.black : UIColor.white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //MARK: - Validatable
    func validate() -> (Bool, String?) {
        self.detail = nil
        
        if regex.count > 0 {
            let test = NSPredicate(format:"SELF MATCHES %@", regex)
            if !test.evaluate(with: text) {
                self.detail = validationMessage
                return (false, nil)
            }
        }
        
        return (true, nil)
    }
}
