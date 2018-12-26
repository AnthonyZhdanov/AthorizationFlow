//
//  String+Utils.swift
//  Example
//
//  Created by Anton Zhdanov on 16.08.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import Foundation

extension String {
    // Convert date string format
    func convertDateFormater(fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        
        guard let date = dateFormatter.date(from: self) else { return "" }
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: date)
    }
    
    // Check is it phone number
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    // Check format is correct
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }
    
    // Check is it fits as password
    func isSufficientComplex() -> Bool {
        let capitalLetterRegEx = ".*[A-Z]+.*"
        let textTestUppercase = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalResult = textTestUppercase.evaluate(with: self)
        
        let numberRegEx = ".*[0-9]+.*"
        let textTestNumber = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberResult = textTestNumber.evaluate(with: self)
        
        let consecutiveRegEx = "(.)\\1"
        let consecutiveResult = self.range(of: consecutiveRegEx, options: .regularExpression) == nil
        
        //        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        //        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        //        let specialresult = texttest2.evaluate(with: self)
        
        return capitalResult && numberResult && consecutiveResult /*&& specialresult*/ && (count >= 7) && (count <= 30)
    }
    
    func isValidName() -> Bool {
        let namingRegEx = "[A-Z][a-zA-Z]*"
        let textTestName = NSPredicate(format:"SELF MATCHES %@", namingRegEx)
        let namingResult = textTestName.evaluate(with: self)
        
        return namingResult && (count >= 1) && (count <= 35)
    }
    
    func isValidLastName() -> Bool {
        let namingRegEx = "[a-zA-z]+([ '-][a-zA-Z]+)*"
        let textTestName = NSPredicate(format:"SELF MATCHES %@", namingRegEx)
        let namingResult = textTestName.evaluate(with: self)
        
        return namingResult && (count >= 1) && (count <= 35)
    }
    
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = dateFormatter.date(from: self)
        
        return date
    }
    
    var customFormatted: String {
        let count = self.count
        return enumerated().map { $0.offset % 3 == 0 && $0.offset != 0 && $0.offset != count - 1 || $0.offset == count - 2 && count % 3 != 0 ? "-\($0.element)" : "\($0.element)" }.joined()
    }
    
    var customFormattedSpace: String {
        let count = self.count
        return enumerated().map { $0.offset % 4 == 0 && $0.offset != 0 && $0.offset != count - 1 ? " \($0.element)" : "\($0.element)" }.joined()
    }
}
