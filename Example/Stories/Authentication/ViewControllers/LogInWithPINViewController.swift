//
//  LogInWithPINViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 3/2/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

final class LogInWithPINViewController: UIViewController {
    
    @IBOutlet private weak var keyboardView: PINKeyboardView!
    private var userCode: [String] = []
    private let symbolsCountLimit = 4

    override func viewDidLoad() {
        super.viewDidLoad()
                
        registerActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
}

private extension LogInWithPINViewController {
    // MARK: - Private methods
    func registerActions() {
        // Actions from keyboard view
        keyboardView.numButtonPressed = { [weak self] input in
            guard let someInput = input else { return }
            
            self?.updateCodeWith(input: someInput)
        }
        
        keyboardView.deleteButtonPressed = { [weak self] in
            self?.deleteLastInput()
        }
        
        keyboardView.forgotButtonPressed = { [weak self] in
            self?.restorePin()
        }
        
        keyboardView.signInButtonPressed = { [weak self] in
            self?.signWithCredentials()
        }
    }
    
    // MARK: - Delegate methods
    func updateCodeWith(input: String) {
        guard userCode.count < symbolsCountLimit else {
            return
        }
        
        userCode.append(input)
        updateUIElements()
        
        // Send request
        guard userCode.count == symbolsCountLimit else {
            return
        }
        
        self.enterAppWithPIN()
    }
    
    func deleteLastInput() {
        guard !userCode.isEmpty else { return }
        
        userCode.removeLast()
        updateUIElements()
    }
    
    func restorePin() {
        print("restore")
    }
    
    func signWithCredentials() {
        performSegue(withIdentifier: "LogIn", sender: self)
    }
    
    func updateUIElements() {
        // Change the filling of circles
        let first = userCode.indices.contains(0)
        let second = userCode.indices.contains(1)
        let third = userCode.indices.contains(2)
        let fourth = userCode.indices.contains(3)
        
        keyboardView.changeIndicatorsState(
            isFirstIsOn: first,
            isSecondIsOn: second,
            isThirdIsOn: third,
            isFourthIsOn: fourth)
        
        // Disable/enable num input by symbols limit
        let isInputAllowed = userCode.count < symbolsCountLimit
        keyboardView.switchKeyboardButtons(areEnabled: isInputAllowed)
    }
    
    // MARK: - Requests
    func enterAppWithPIN() {
        guard let identifier = SessionManager.shared.readItem(service: "AuthIdentifier") else {
            showAllertiWith(message: "Please use your login and password to log in", textFieldToBecomeResponder: nil)
            
            return
        }
        
        self.displayNavBarActivity()
        let somePIN = userCode.joined(separator: "") // Merging input in one string
        
        tryToLoginUserWith(userPIN: somePIN, uuid: identifier) { [unowned self] (error, success, message) in
            self.dismissNavBarActivity()
            
            if success {
                self.showAllertiWith(message: "Success", textFieldToBecomeResponder: nil)
                // self.performSegue(withIdentifier: "Dashboard", sender: self)
            } else {
                self.userCode.removeAll()
                self.updateUIElements()
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something went wrong", textFieldToBecomeResponder: nil)
            }
        }
    }
    
    func tryToLoginUserWith(userPIN: String, uuid: String, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let loginUser = LoginUserByPINRequest.init(owner: ObjectIdentifier(self), pinCode: userPIN, uuid: uuid)
//
//        loginUser.completion = { request, error in
//            guard error == nil else {
//                var message: String?
//
//                if let webServiceError = error as? Diaspora.Request.Response.WebserviceError {
//                    message = webServiceError.message
//                }
//
//                resultBlock(error, false, message)
//
//                return
//            }
//
            resultBlock(nil, true, nil)
//        }
//
//        Dispatcher.shared.processRequest(request: loginUser)
    }
}
