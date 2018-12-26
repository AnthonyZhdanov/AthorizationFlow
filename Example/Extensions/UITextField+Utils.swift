//
//  UITextField+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

extension UITextField {
    //Textfield with date picker
    func addOwnDatePicker(value: String?, format: String, limited: Bool) {
        let datePicker = UIDatePicker()
        if limited {
            datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
            datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -150, to: Date())
        }
        if let date = value?.toDate(format: format) {
            datePicker.date = date
        }
        
        datePicker.datePickerMode = .date
        
        if format == "dd/MM/yyyy" {
            datePicker.addTarget(self, action: #selector(dateChangedObliqueFormat(_:)), for: .valueChanged)
        } else {
            datePicker.addTarget(self, action: #selector(dateBeenChanged(_:)), for: .valueChanged)
        }
        
        inputView = datePicker
    }
    
    @objc func dateBeenChanged(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        text = formatter.string(from: datePicker.date)
    }
    
    @objc func dateChangedObliqueFormat(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        text = formatter.string(from: datePicker.date)
    }
}
