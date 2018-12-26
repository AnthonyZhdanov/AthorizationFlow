//
//  WelcomeViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 19.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController {

    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var termsConditionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "tokenExist")
        setupMultipleTapLabel()
        validateIdentifier()
        
        NotificationCenter.default.addObserver(self, selector: #selector(popToRoot), name: NSNotification.Name(rawValue: "Welcome"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        removeCookies()
        self.navigationItem.setHidesBackButton(true, animated: false)
        if deviceIsPirated() {
            self.view.isUserInteractionEnabled = false
            showAllertiWith(message: "Your device is jailbroken - you can not run this app", textFieldToBecomeResponder: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier else {
            assertionFailure("segue had no ID")
            
            return
        }
        
        switch identifier {
        case "ContactUs":
            print("ContactUs")
            let destinationController = segue.destination as? ContactUsViewController
            destinationController?.setInAppMode(active: false)
        case "Terms":
            print("Terms")
//            let destinationController = segue.destination as? InformationViewController
//            destinationController?.setController(state: .termsConditions, authorized: false)
        case "Privacy":
            print("Privacy")
//            let destinationController = segue.destination as? InformationViewController
//            destinationController?.setController(state: .privacy, authorized: false)
        case "FAQ":
            print("FAQ")
//            let destinationController = segue.destination as? InformationViewController
//            destinationController?.setController(state: .faq, authorized: false)
        default:
            break
        }
    }
}

private extension WelcomeViewController {
    func setupMultipleTapLabel() {
        let text = (termsConditionsLabel.text)!
        let boldAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms & Conditions")
        boldAttriString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 15), range: range1)
        let range2 = (text as NSString).range(of: "Privacy Policy")
        boldAttriString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 15), range: range2)
        termsConditionsLabel.attributedText = boldAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        termsConditionsLabel.isUserInteractionEnabled = true
        termsConditionsLabel.addGestureRecognizer(tapAction)
    }
    
    func removeCookies() {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (termsConditionsLabel.text)!
        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        // TODO: update when data will be available
        if gesture.didTapAttributedTextInLabel(label: termsConditionsLabel, inRange: termsRange) {
//            performSegue(withIdentifier: "Terms", sender: self)
            print("Terms of service")
        } else if gesture.didTapAttributedTextInLabel(label: termsConditionsLabel, inRange: privacyRange) {
//            performSegue(withIdentifier: "Privacy", sender: self)
            print("Privacy policy")
        } else {
            print("Tapped none")
        }
    }
    
    // MARK: - Handle Actions
    @IBAction func logInButtonPressed(_ sender: Any) {
        SessionManager.shared.pinExist() ?
            self.performSegue(withIdentifier: "LogInByPIN", sender: self) :
            self.performSegue(withIdentifier: "LogIn", sender: self)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "SignUp", sender: self)
    }
    // TODO: Update in future
    @IBAction func faqButtonPressed(_ sender: Any) {
//        performSegue(withIdentifier: "FAQ", sender: self)
    }
    
    @IBAction func contactUsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ContactUs", sender: self)
    }
    
    @objc private func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Networking
    func validateIdentifier() {
        guard SessionManager.shared.pinExist() else { return }
        
//        guard let identifier = SessionManager.shared.readItem(service: "AuthIdentifier") else {
//            SessionManager.shared.setPin(isExist: false)
//
//            showAllertiWith(message: "You can not Log In by PIN if your phone is not secured by password or other way", textFieldToBecomeResponder: nil)
//
//            return
//        }
        let identifier = "dsaagsadgsagsadgsa"
        
        displayNavBarActivity()

        validationRequest(identifier: identifier) { [unowned self] (error, success) in
            self.dismissNavBarActivity()

            SessionManager.shared.setPin(isExist: success)
        }
    }
    
    func validationRequest(identifier: String, resultBlock: @escaping (Error?, Bool) -> ()) {
//        let validationRequest = ValidateIdRequest.init(owner: ObjectIdentifier(self), identifier: identifier)
//
//        validationRequest.completion = { request, error in
//            guard error == nil else {
//                resultBlock(error, false)
//
//                return
//            }
//
//            if let response = request.response as? ValidateIdRequest.ValidateIdResponse {
//                response.valid ? resultBlock(nil, true) : resultBlock(nil, false)
//            }
//        }
//
//        Dispatcher.shared.processRequest(request: validationRequest)
        
        resultBlock(nil, true)
    }
    
    func deviceIsPirated() -> Bool {
        // Check 1 : existence of files that are common for jailbroken devices
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || FileManager.default.fileExists(atPath: "/bin/bash")
            || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
            || FileManager.default.fileExists(atPath: "/etc/apt")
            || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
            || UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {
            return true
        }
        // Check 2 : Reading and writing in system directories (sandbox violation)
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile: "/private/JailbreakTest.txt", atomically: true, encoding: String.Encoding.utf8)
            //Device is jailbroken
            return true
        } catch {
            return false
        }
    }
}
