//
//  AccountDataModel.swift
//  Example
//
//  Created by Anton Zhdanov on 6/7/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import Foundation

struct AccountData {
    
    private(set) var availableBalance: String
    private(set) var balanceCurrency: String?
    private(set) var countryCode: String?
    private(set) var ledgerBalance: String?
    private(set) var currencyCode: String
    private(set) var currencySymbol: String
    
    init(data: Dictionary <String, Any>) {
        availableBalance = data["availableBalance"] as? String ?? ""
        
        if let tryBalanceCurrency = data["balanceCurrency"] as? String {
            balanceCurrency = tryBalanceCurrency
        }
        if let tryCountryCode = data["countryCode"] as? String {
            countryCode = tryCountryCode
        }
        if let tryLedgerBalance = data["ledgerBalance"] as? String {
            ledgerBalance = tryLedgerBalance
        }
        
        guard let currency = data["currency"] as? Dictionary<String, String>, let code = currency["code"], let symbol = currency["symbol"] else {
            currencyCode = ""
            currencySymbol = ""
            
            return
        }
        
        self.currencyCode = code
        self.currencySymbol = symbol
    }
    
    func currentBalanceAdapted() -> String {
        let currentBalance = availableBalance.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
        let doubleValue = Double(currentBalance) ?? 0.0
        
        return "\(currencySymbol) \(String(format:"%.2f", doubleValue))"
    }
    
    func currentBalanceDouble() -> Double {
        return Double(availableBalance) ?? 0.0
    }
}

struct AccountTransaction {
    
    private(set) var balance: String?
    private(set) var date: String?
    private(set) var datePosted: String
    private(set) var narration: String?
    private(set) var partTransactionType: String
    private(set) var transactionAmount: String
    private(set) var transactionDate: String?
    private(set) var transactionID: String?
    private(set) var transactionSerialNumber: String?
    private(set) var transactionSubtype: String?
    
    init(data: Dictionary <String, Any>) {
        datePosted = data["datePosted"] as? String ?? "-"
        partTransactionType = data["partTransactionType"] as? String ?? "-"
        transactionAmount = data["transactionAmount"] as? String ?? "-"
        
        balance = data["balance"] as? String
        date = data["date"] as? String
        narration = data["narration"] as? String
        transactionDate = data["transactionDate"] as? String
        transactionSerialNumber = data["transactionSerialNumber"] as? String
        transactionSubtype = data["transactionSubtype"] as? String
    }
    
    func datePostedFormatted() -> String {
        guard let date = datePosted.toDate(format: "yyyyMMddHHmmss") else { return datePosted }
        
        return date.toString(format: "dd MMM, yyyy, HH:mm")
    }
}

struct AccountStatus {
    
    private(set) var accountNumber: String?
    private(set) var currencyCode: String?
    private(set) var currencySymbol: String?
    private(set) var balance: String?
    private(set) var active: String?
    
    init(data: Dictionary<String, Any>) {
        accountNumber = data["accountNumber"] as? String
        balance = data["balance"] as? String
        active = data["active"] as? String
        
        guard let currency = data["currency"] as? Dictionary<String, String> else { return }
        
        currencyCode = currency["code"]
        currencySymbol = currency["symbol"]
    }
    
    func accountNumberFormatted() -> String {
        guard let number = accountNumber else { return "-" }
        
        return number.customFormatted
    }
    
    func currentBalanceAdapted() -> String {
        guard let symbol = currencySymbol, let someBalance = balance else { return "-" }
        
        return "\(symbol) \(someBalance)"
    }
    
    func balanceParameters() -> (balanceValue: Double, currency: String) {
        guard let symbol = currencySymbol, let someBalance = balance, let doubleValue =
            Double(someBalance) else { return (0.0, "-") }
        
        return (doubleValue, symbol)
    }
}

final class AccountDataModel: Equatable {
    
    private(set) var accountNumber: String
    private(set) var active: Bool
    private(set) var accountData: AccountData
    private(set) var accountTransactions: [AccountTransaction]?
    
    init?(data: Dictionary <String, Any>) {
        guard let accNumber = data["accountNumber"] as? String, let isActive = data["active"] as? Bool else { return nil }
        
        accountNumber = accNumber
        active = isActive
        
        guard let someData = data["transactions"] as? Dictionary <String, Any> else { return nil }
        
        accountData = AccountData.init(data: someData)
        var sometransactions: [AccountTransaction] = []
        
        if let transactionInfo = someData["transactionInfo"] as? Dictionary <String, Any>, let transactions = transactionInfo["transactions"] as? [Dictionary <String, Any>] {
            for transaction in transactions {
                let someTransaction = AccountTransaction.init(data: transaction)
                sometransactions.append(someTransaction)
            }
            
            accountTransactions = sometransactions.sorted(by: { $0.datePosted > $1.datePosted })
        }
    }
    
    func accountNumberFormatted() -> String {
        return accountNumber.customFormatted
    }
    
    // MARK: Equatable
    static func == (lhs: AccountDataModel, rhs: AccountDataModel) -> Bool {
        return false
    }
}
