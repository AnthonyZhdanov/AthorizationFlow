//
//  SessionManager.swift
//  Example
//
//  Created by Anton Zhdanov on 6/15/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import Foundation
import LocalAuthentication
import Security

final class SessionManager {
    
    static let shared = SessionManager()
    let tokenExistsDefaultsKey = "TokenExist"
    private var accountData: [AccountDataModel] = []
    private var userData: ExampleUser?
    private let accountName = "DiasporaUser"
    private let accessGroup: String? = nil
    private let tokenServiceKey = "Token"
    private let refreshTokenServiceKey = "RefreshToken"
    
    // MARK: Lifecycle
    private init() {}
    
    // MARK: Accounts Logic
    func createAccountsFrom(list: [Dictionary <String, Any>]) {
        accountData.removeAll()
        
        for item in list {
            if let account = AccountDataModel.init(data: item) {
                accountData.append(account)
            }
        }
    }
    
    func activeAccounts() -> [AccountDataModel] {
        return accountData.filter { $0.active == true }
    }
    
    func blockedAccounts() -> [AccountDataModel] {
        return accountData.filter { $0.active == false }
    }
    
    func allAccounts() -> [AccountDataModel] {
        return accountData
    }
    
    // MARK: User Logic
    func createUserFrom(userDictionary: Dictionary<String, Any>) {
        guard let email = userDictionary["email"] as? String,
            let firstName = userDictionary["firstName"] as? String,
            let lastName = userDictionary["lastName"] as? String,
            let phoneNumber = userDictionary["phoneNumber"] as? String,
            let dateBirth = userDictionary["dateBirth"] as? String,
            let country = userDictionary["country"] as? String,
            let uuid = userDictionary["uuid"] as? String,
            let pinExist = userDictionary["pinExist"] as? Bool,
            let isDeactivated = userDictionary["deactivated"] as? Bool else {
                return
        }
        
        // Save ID only if passcode protection is enabled
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            setPin(isExist: pinExist)
            saveItem(value: uuid, service: "AuthIdentifier")
        } else {
            setPin(isExist: false)
            deleteItem(service: "AuthIdentifier")
        }
        
        let diasporaUser = ExampleUser.init(
            country: country,
            dateBirth: dateBirth,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            deactivated: isDeactivated)
        
        userData = diasporaUser
        
        guard let tokenDto = userDictionary["tokenDto"] as? Dictionary<String, String> else { return }
        
        updateTokens(dataDictionary: tokenDto)
    }
    
    func updateTokens(dataDictionary: Dictionary<String, String>) {
        guard let token = dataDictionary["token"],
            let refreshToken = dataDictionary["refreshToken"] else {
                UserDefaults.standard.set(false, forKey: "TokenExist")
                
                return
        }
        
        // TODO: fix uppercase/lowercase Key names
        saveItem(value: token, service: "Token")
        saveItem(value: refreshToken, service: "RefreshToken")
        UserDefaults.standard.set(true, forKey: "TokenExist")
    }
    
    func currentUser() -> ExampleUser? {
        return userData
    }
    
    func setUserActive() {
        userData?.deactivated = false
    }
    
    func currentAccountDeactivated() -> Bool {
        guard let user = userData else { return false }
        
        return user.deactivated
    }
    
    // MARK: Keychain
    private func saveItem(value: String, service: String) {
        do {
            let someId = KeychainService(service: service,
                                         account: accountName,
                                         accessGroup: accessGroup)
            try someId.saveItem(value)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func readItem(service: String) -> String? {
        if service == "AuthIdentifier", !LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            deleteItem(service: service)
            
            return nil
        }
        
        do {
            let someId = KeychainService(service: service,
                                         account: accountName,
                                         accessGroup: accessGroup)
            let keychainIdentifier = try someId.readItem()
            
            return keychainIdentifier
        } catch {
            return nil
        }
    }
    
    private func deleteItem(service: String) {
        do {
            let someId = KeychainService(service: service,
                                         account: accountName,
                                         accessGroup: accessGroup)
            try someId.deleteItem()
        } catch {
            fatalError("Error deleting from keychain - \(error)")
        }
    }
    
    func setPin(isExist: Bool) {
        UserDefaults.standard.set(isExist, forKey: "pinExist")
    }
    
    func pinExist() -> Bool {
        return UserDefaults.standard.bool(forKey: "pinExist")
    }
    
    // MARK: Logout
    func logOutUser(completion: () -> Void) {
        accountData = []
        userData = nil
        SessionManager.shared.deleteItem(service: tokenServiceKey)
        SessionManager.shared.deleteItem(service: refreshTokenServiceKey)
        UserDefaults.standard.set(false, forKey: tokenExistsDefaultsKey)
        
        completion()
    }
}
