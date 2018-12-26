//
//  LogInViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 20.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

final class LogInViewController: UIViewController {

    @IBOutlet private weak var theScrollView: UIScrollView!
    @IBOutlet private weak var loginTextField: HintTextField!
    @IBOutlet private weak var passwordTextField: HintTextField!
    @IBOutlet private weak var signUpLabel: UILabel!
    // Alert
    private weak var actionToEnable : UIAlertAction?
    private let restorePasswordCodeLength: Int = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTapLabel()
        loginTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier else {
            assertionFailure("segue had no ID")
            
            return
        }
        
        switch identifier {
        case "ContactUs":
            let destinationController = segue.destination as? ContactUsViewController
            destinationController?.setInAppMode(active: false)
        case "FAQ":
            print("FAQ")
//            let destinationController = segue.destination as? InformationViewController
//            destinationController?.setController(state: .faq, authorized: false)
        default:
            break
        }
    }
}

private extension LogInViewController {
    // MARK: - Tapable Label
    func setupTapLabel() {
        let text = (signUpLabel.text)!
        let boldAttriString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "Sign Up")
        boldAttriString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 15), range: range)
        signUpLabel.attributedText = boldAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tapAction)
    }
    
    func prepareRestoreData(code: String?) {
        guard let restoreCode = code else { return }
        
        displayNavBarActivity()
        
        verifyRestore(code: restoreCode) { [unowned self] (error, success, message) in
            self.dismissNavBarActivity()
            
            success ?
                self.showAllertiWith(message: "New password have been sent to your phone number", textFieldToBecomeResponder: nil) :
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something went wrong", textFieldToBecomeResponder: nil)
        }
    }
    
    // MARK: - Handle Actions
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (signUpLabel.text)!
        let range = (text as NSString).range(of: "Sign Up")
        
        if gesture.didTapAttributedTextInLabel(label: signUpLabel, inRange: range) {
            performSegue(withIdentifier: "SignUp", sender: self)
        }
        else {
            print("Tapped none")
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        guard let login = loginTextField.text, login.isPhoneNumber else {
            showAllertiWith(message: "Please, use valid phone number", textFieldToBecomeResponder: loginTextField)
            
            return
        }
        
        guard let password = passwordTextField.text, password.isSufficientComplex() else {
            showAllertiWith(message: "Password format is invalid", textFieldToBecomeResponder: passwordTextField)
            
            return
        }
        
        displayNavBarActivity()
        
        tryToLoginUserWith(login: login, password: password) { [unowned self] (error, success, message) in
            self.dismissNavBarActivity()
            
            success ?
                self.performSegue(withIdentifier: "Dashboard", sender: self) :
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something went wrong", textFieldToBecomeResponder: nil)
        }
    }
    
    func handleRestorePassword() {
        let title = "Restore Password"
        let message = "Please enter 9 digit code\n sent to your phone"
        let placeholder = "XXXXXXXXX"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: { [unowned self] (textField) in
            textField.keyboardType = .numberPad
            textField.textAlignment = .center
            textField.placeholder = placeholder
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        })
        
        let action = UIAlertAction(title: "Restore", style: .default) { [unowned self] (alertAction) in
            guard let textField = alert.textFields?.first else { return }
            self.prepareRestoreData(code: textField.text)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.actionToEnable = action
        action.isEnabled = false
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func textChanged(_ sender:UITextField) {
        guard let text = sender.text else {
            self.actionToEnable?.isEnabled = false
            
            return
        }
        
        self.actionToEnable?.isEnabled = text.count == restorePasswordCodeLength
    }
    // TODO: Rework for FAQ data (when will be available
    @IBAction func faqButtonPressed(_ sender: Any) {
//        performSegue(withIdentifier: "FAQ", sender: self)
    }
    
    @IBAction func contactUsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ContactUs", sender: self)
    }
    
    @IBAction func forgotButtonPressed(_ sender: Any) {
        guard let loginFieldText = loginTextField.text, loginFieldText.isPhoneNumber else {
            showAllertiWith(message: "Phone number is invalid", textFieldToBecomeResponder: nil)
            
            return
        }

        displayNavBarActivity()
        
        restorePasswordWith(value: loginFieldText) { [unowned self] (error, success, message) in
            self.dismissNavBarActivity()
            
            success ?
                self.handleRestorePassword() :
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something went wrong", textFieldToBecomeResponder: nil)
        }
    }
    
    // MARK: - Requests
    func tryToLoginUserWith(login: String, password: String, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let loginUser = LoginUserRequest.init(owner: ObjectIdentifier(self), login: login, password: password)
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
//            resultBlock(nil, true, nil)
//        }
//
//        Dispatcher.shared.processRequest(request: loginUser)
        
        resultBlock(nil, false, nil)
    }
    
    func restorePasswordWith(value: String, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let restore = ForgotPasswordRequest.init(owner: ObjectIdentifier(self), value: value)
//
//        restore.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: restore)
    }
    
    func verifyRestore(code: String, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let restore = CodePasswordVerifyRequest.init(owner: ObjectIdentifier(self), value: code)
//
//        restore.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: restore)
    }
}

// MARK: UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.first != "+" {
            textField.text?.insert("+", at: text.startIndex)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.first != "+" {
            textField.text?.insert("+", at: text.startIndex)
        }
    }
}
