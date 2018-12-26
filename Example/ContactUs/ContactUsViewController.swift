//
//  ContactUsViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 20.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

final class ContactUsViewController: UIViewController {

    @IBOutlet private weak var emailTextField: HintTextField!
    @IBOutlet private weak var messageTextView: HintTextView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var underMessageView: UIView!
    
    private let maxSymbolsCount: Int = 250
    private var inAppMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        hideKeyboardOnTapArround()
        setupTextView()
        
        if inAppMode {
            switchTheme()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.previousNextDisplayMode = .Default
    }
    
    public func setInAppMode(active: Bool) {
        self.inAppMode = active
    }
}

private extension ContactUsViewController {
    func setupTextView() {
        messageTextView.placeholder = "Message"
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.sizeToFit()
        messageTextView.isScrollEnabled = false
        messageTextView.delegate = self
        
        let name = NSNotification.Name.UITextViewTextDidChange
        let selector = #selector(textViewDidChange)
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: self)
    }
    
    func switchTheme() {
        actionButton.setTitleColor(UIColor.white, for: .normal)
        actionButton.setBackgroundImage(#imageLiteral(resourceName: "button_pink"), for: .normal)
        emailTextField.isDark = true
        messageTextView.placeholderColor = .gray
        messageTextView.titleColor = .gray
        messageTextView.textColor = .black
        underMessageView.backgroundColor = .lightGray
        scrollView.backgroundColor = .white
    }
    
    // MARK: Request
    func sendMessage(parameters: [String: Any], resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let sendMessage = MessageSendRequest.init(owner: ObjectIdentifier(self), params: parameters)
//
//        sendMessage.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: sendMessage)
    }
    
    // MARK: - Handle Actions
    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, email.isValidEmail() else {
            showAllertiWith(message: "Email format is invalid", textFieldToBecomeResponder: emailTextField)
            
            return
        }
        
        guard let message = messageTextView.text, !message.isEmpty else {
            showAllertiWith(message: "Message is empty", textFieldToBecomeResponder: nil)
            
            return
        }
        
        inAppMode ? displayFullScreenActivity() : displayNavBarActivity()
        
        let sendData = ["from": email,
                        "message": message]
        
         sendMessage(parameters: sendData) { [unowned self] (error, success, message) in
            self.inAppMode ? self.dismissFullScreenActivity() : self.dismissNavBarActivity()
            success ?
                self.showAllertiWith(message: "Message have been sent", textFieldToBecomeResponder: nil) :
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something Went Wrong", textFieldToBecomeResponder: nil)
        }
        
    
    }
    
    func hideKeyboardOnTapArround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UITextViewDelegate
extension ContactUsViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let count = messageTextView.text.count
        
        DispatchQueue.main.async {
            self.countLabel.text = "\(count)"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        return newText.count <= maxSymbolsCount
    }
}
