//
//  StepTwoSignUpViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 20.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

private enum ControllerState {
    case emailVerify, phoneVerify, pinCreate
}

final class StepTwoSignUpViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var resendButton: UIButton!
    @IBOutlet private weak var verifyNumButton: UIButton!
    @IBOutlet private weak var stepImageView: UIImageView!
    @IBOutlet private weak var inputStackView: UIStackView!
    // View to hide in case "Add PIN" functionality + helpers
    @IBOutlet private weak var additionalView: UIView!
    @IBOutlet private weak var coverViewConstraint: NSLayoutConstraint!
    
    private var phoneOrEmail: String?
    private var controllerState = ControllerState.pinCreate
    private let inputFieldsToConfirmPhone = 9
    private let inputFieldsToCreatePIN = 4
    private let spacingBetweenFieldsToConfirmPhone: CGFloat = 10
    private let spacingBetweenFieldsToCreatePIN: CGFloat = 30
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let count = controllerState == .pinCreate ? inputFieldsToCreatePIN : inputFieldsToConfirmPhone
        inputStackView.spacing = controllerState == .pinCreate ? spacingBetweenFieldsToCreatePIN : spacingBetweenFieldsToConfirmPhone
        for _ in 0..<count {
            let someField = ReturnableTextField()
            someField.font = UIFont.systemFont(ofSize: 32)
            someField.textColor = UIColor.white
            someField.keyboardType = .numberPad
            someField.textAlignment = .center
            inputStackView.addArrangedSubview(someField)
        }
        setupControllerElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.stepImageView.image = #imageLiteral(resourceName: "step")
    }
    
    public func setForVerificationBy(email: Bool, parameterName: String) {
        controllerState = email ? .emailVerify : .phoneVerify
        phoneOrEmail = parameterName
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier else {
            assertionFailure("segue had no ID")
            
            return
        }
        
        switch identifier {
        case "StepThree":
            guard let phone = phoneOrEmail else { return }
            
            let destinationController = segue.destination as? StepThreeSignUpViewController
            destinationController?.setPhone(number: phone)
        default:
            break
        }
    }
}

private extension StepTwoSignUpViewController {
    // MARK: - Private
    func setupControllerElements() {
        guard let fields = inputStackView.arrangedSubviews as? [ReturnableTextField] else { return }
        
        fields.forEach({ $0.addTarget(self, action: #selector(textChanged), for: .editingChanged) })
        // Setup by state
        switch controllerState {
        case .emailVerify, .phoneVerify:
            titleLabel.text = "Please enter a 9 digit verification\ncode sent to " + (phoneOrEmail ?? "specified address")
        case .pinCreate:
            navigationItem.setHidesBackButton(true, animated: false)
            additionalView.isHidden = true
            coverViewConstraint.constant = 0
            title = "Setup a PIN-code"
            titleLabel.text = "Please set a PIN-code to protect your\naccount and fast sign in"
            verifyNumButton.setTitle("Setup a PIN-code", for: .normal)
            resendButton.isHidden = true
        }
    }
    
    // MARK: - Target Action
    @objc func textChanged(sender: UITextField) {
        guard let someText = sender.text, !someText.isEmpty else { return }
        
        if sender == inputStackView.arrangedSubviews.last {
            view.endEditing(true)
        }
        else {
            IQKeyboardManager.shared.goNext()
        }
    }
    
    // MARK: - Handle Actions
    @IBAction func verifyButtonPressed(_ sender: Any) {
        guard let fields = inputStackView.arrangedSubviews as? [ReturnableTextField], fields.compactMap({ $0.text?.isEmpty }).contains(true) == false else {
            self.showAllertiWith(message: "Please fill all the fields to continue", textFieldToBecomeResponder: nil)
            return
        }
        
        displayNavBarActivity()
        let result = fields.compactMap { $0.text }.joined()
        
        let isEmailCheck = controllerState == .emailVerify
        
        switch controllerState {
        case .emailVerify, .phoneVerify:
            verifyWith(code: result, byEmail: isEmailCheck) { [unowned self] (error, success, message) in
                if success {
                    self.goToNext()
                }
                else {
                    self.dismissNavBarActivity()
                    
                    self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something Went Wrong", textFieldToBecomeResponder: nil)
                }
                
            }
        case .pinCreate:
            addPIN(code: result) { [unowned self] (error, success, message) in
                self.dismissNavBarActivity()
                
                if success {
                    self.updateUser {
                        self.performSegue(withIdentifier: "LinkAccount", sender: self)
                    }
                }
                else {
                    self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something Went Wrong", textFieldToBecomeResponder: nil)
                }
            }
        }
    }
    
    @IBAction func resendButtonPressed(_ sender: Any) {
        displayNavBarActivity()
        
        resendCode { [unowned self] (error, success, message) in
            self.dismissNavBarActivity()
            
            success ?
                self.showAllertiWith(message: "Re-sent", textFieldToBecomeResponder: nil) :
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something Went Wrong", textFieldToBecomeResponder: nil)
        }
    }
    
    // MARK: - Requests
    func verifyWith(code: String, byEmail: Bool, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let verifyCode = VerifyCodeRequest.init(owner: ObjectIdentifier(self), codeToVerify: code, viaEmail: byEmail)
//
//        verifyCode.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: verifyCode)
    }
    
    func resendCode(resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let isEmail = controllerState == .emailVerify
//
//        let resendCode = ResendVerificationCodeRequest.init(owner: ObjectIdentifier(self), viaEmail: isEmail)
//
//        resendCode.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: resendCode)
    }
    
    func addPIN(code: String, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let addPinCode = AddPINRequest.init(owner: ObjectIdentifier(self), pinCodeToAdd: code)
//
//        addPinCode.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: addPinCode)
    }
    
    // MARK: - Redirect to next
    func goToNext() {
        // Image on top
        self.stepImageView.image = #imageLiteral(resourceName: "step_succes")
        
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.dismissNavBarActivity()
            
            self.performSegue(withIdentifier: "StepThree", sender: self)
        }
    }
    
    // MARK: - Update Storage
    func updateUser(completionBlock: @escaping () -> ()) {
        SessionManager.shared.currentUser() != nil ?
            SessionManager.shared.setPin(isExist: true) :
            showAllertiWith(message: "You need to logIn once again to continue this action - cache has been cleared", textFieldToBecomeResponder: nil)
        
        completionBlock()
    }
}
