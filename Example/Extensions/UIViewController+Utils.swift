//
//  UIViewController+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

protocol Validatable {
    func validate() -> (Bool, String?)
}

extension UIViewController: Validatable {
    func validate() -> (Bool, String?) {
        var validationErrors = ""
        var validatableIsResponder = false
        var valid = true
        for item in view.allSubViews {
            if let validatableItem = item as? Validatable {
                let (status, message) = validatableItem.validate()
                if !status {
                    valid = false
                }
                if !status, let message = message {
                    validationErrors.append("\(message)\n")
                }
                // Set responder to first textField with wrong input
                if !validatableIsResponder, !valid {
                    item.becomeFirstResponder()
                    validatableIsResponder = !validatableIsResponder
                }
            }
        }
        
        if validationErrors.count > 0 {
            return (valid, validationErrors)
        }
        
        return (valid, nil)
    }
}

// MARK: - UIViewController
extension UIViewController {
    // Show Allert
    func showAllertiWith(/*title: String?,*/ message: String, /*style: UIAlertControllerStyle*/ textFieldToBecomeResponder: UITextField?) {
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (alertView: UIAlertAction) in
            self.navigateTo(textfield: textFieldToBecomeResponder)
        }
        
        alertView.addAction(okAction)
        
        if presentedViewController == nil {
            present(alertView, animated: true, completion: nil)
        }
    }
    
    func navigateTo(textfield: UITextField?) {
        guard let field = textfield else {
            return
        }
        
        field.becomeFirstResponder()
    }
    
    // MARK: - Activity Indicator
    func displayNavBarActivity() {
        view.isUserInteractionEnabled = false
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        
        navigationItem.leftBarButtonItem = item
    }
    
    func dismissNavBarActivity() {
        view.isUserInteractionEnabled = true
        
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Full Screen Activity Indicator
    func displayFullScreenActivity() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let container = ActivityContainerView()
        container.frame = window.frame
        container.center = window.center
        window.addSubview(container)
        container.startActivityAnimation()
    }
    
    func dismissFullScreenActivity() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        for view in window.subviews {
            if view is ActivityContainerView {
                view.removeFromSuperview()
            }
        }
    }
}
