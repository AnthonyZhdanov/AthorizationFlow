//
//  ReturnableTextField.swift
//  Example
//
//  Created by Anton Zhdanov on 6/20/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

final class ReturnableTextField: UITextField {
    
    private var placeholderColor: UIColor?
    private let pathLineWidth: CGFloat = 2.0
    
    var colorOfPlaceholder: UIColor {
        set {
            placeholderColor = colorOfPlaceholder
        }
        get {
            return (placeholderColor ?? textColor ?? .white).withAlphaComponent(0.3)
        }
    }
    
    override func awakeFromNib() {
        // Custom Placeholder
        super.awakeFromNib()
        
    }
    
    // Move to previous field by "delete" button even if field is empty(delegate method is not available in this case)
    override func deleteBackward() {
        super.deleteBackward()
        self.text = ""
        self.attributedPlaceholder = NSAttributedString (
            string: "X",
            attributes: [NSAttributedStringKey.foregroundColor: self.colorOfPlaceholder,
                         NSAttributedStringKey.font: font ?? UIFont.systemFont(ofSize: 32)])
        
        IQKeyboardManager.shared.goPrevious()
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        self.text = ""
        return result
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = pathLineWidth
        tintColor = textColor == .white ? .white : UIColor.colorFrom(hex: "FF4953")
        tintColor.setStroke()
        
        path.stroke()
        
        self.attributedPlaceholder = NSAttributedString(
            string: "X",
            attributes: [NSAttributedStringKey.foregroundColor: self.colorOfPlaceholder,
                         NSAttributedStringKey.font: font ?? UIFont.systemFont(ofSize: 32)])
    }
    
    // Restrict paste action - to secure fields from input via "Paste"
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) { return false }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
