//
//  StepOneSignUpViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 3/6/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

final class StepOneSignUpViewController: UIViewController {

    @IBOutlet private weak var numberTextField: HintTextField!
    @IBOutlet private weak var verificationNumberTextField: HintTextField!
    @IBOutlet private weak var dateBirthTextField: HintTextField!
    @IBOutlet private weak var stepImageView: UIImageView!
    @IBOutlet private weak var checkboxImageView: UIImageView!
    @IBOutlet private weak var signInLabel: UILabel!
    // Additional View and constraint to cover/show this View
    @IBOutlet private weak var additionalFieldsView: UIView!
    @IBOutlet private weak var addifionalViewHeigthContstraint: NSLayoutConstraint!
    private let heightToShowView: CGFloat = 151.0
    private var isViewHidden = true
    
    //TODO: Change requests from email to phone
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupElements()
        setupTapLabel()
        
        numberTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.stepImageView.image = #imageLiteral(resourceName: "step")        
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier else {
            assertionFailure("SignUpViewController segue had no ID")
            
            return
        }
        
        switch identifier {
        case "StepTwo":
            let email = numberTextField.text ?? "Your phone number"
            
            let destinationController = segue.destination as? StepTwoSignUpViewController
            destinationController?.setForVerificationBy(email: false, parameterName: email)
        default:
            break
        }
    }
}

private extension StepOneSignUpViewController {
    // MARK: - Setup of switchable elements
    func setupElements() {
        DispatchQueue.main.async {
            self.additionalFieldsView.isHidden = self.isViewHidden
            self.addifionalViewHeigthContstraint.constant = self.isViewHidden ? 0.0 : self.heightToShowView
            //Checkbox Image
            self.checkboxImageView.image = self.isViewHidden ? #imageLiteral(resourceName: "checkbox_off") : #imageLiteral(resourceName: "checkbox_on")
            self.dateBirthTextField.addOwnDatePicker(value: nil, format: "dd/MM/yyyy", limited: true)
        }
    }
    
    // MARK: - Tapable Label
    func setupTapLabel() {
        let text = (signInLabel.text)!
        let boldAttriString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "Sign In")
        boldAttriString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 15), range: range)
        signInLabel.attributedText = boldAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        signInLabel.isUserInteractionEnabled = true
        signInLabel.addGestureRecognizer(tapAction)
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (signInLabel.text)!
        let range = (text as NSString).range(of: "Sign In")
        
        if gesture.didTapAttributedTextInLabel(label: signInLabel, inRange: range) {
            performSegue(withIdentifier: "SignIn", sender: self)
        }
        else {
            print("Tapped none")
        }
    }
    
    // MARK: - Handle Actions
    @IBAction func accountButtonPressed(_ sender: UIButton) {
        isViewHidden = !isViewHidden
        setupElements()
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        isViewHidden ? self.composeNonUBAData() : self.composeUBAData()
    }
    
    // MARK: - Compose data
    func composeNonUBAData() {
        guard let phone = numberTextField.text, phone.isPhoneNumber else {
            showAllertiWith(message: "Please enter correct phone number", textFieldToBecomeResponder: numberTextField)
            
            return
        }
        
        displayNavBarActivity()
        
        registerPhone(number: phone) { [unowned self] (error, success, message) in
            if success {
                self.goToNext()
            }
            else {
                self.dismissNavBarActivity()
                
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something Went Wrong", textFieldToBecomeResponder: nil)
            }
        }
    }

    func composeUBAData() {
        guard let phone = numberTextField.text, phone.isValidEmail() else {
            showAllertiWith(message: "Please enter correct phone number", textFieldToBecomeResponder: numberTextField)
            
            return
        }
        
        guard let verificationNumber = verificationNumberTextField.text, !verificationNumber.isEmpty else {
            showAllertiWith(message: "Please enter correct BVN", textFieldToBecomeResponder: verificationNumberTextField)
            
            return
        }
        
        guard let date = dateBirthTextField.text, !date.isEmpty else {
            showAllertiWith(message: "Please select date of birth", textFieldToBecomeResponder: dateBirthTextField)
            
            return
        }
        
        displayNavBarActivity()
        
        let dateBirth = date.convertDateFormater(fromFormat: "dd/MM/yyyy", toFormat: "yyyy-MM-dd")
        
        registerWith(phone: phone, bvn: verificationNumber, dateBirth: dateBirth)
    }
    
    // MARK: - Requests
    func registerPhone(number: String, resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let registerPhone = RegisterPhoneRequest.init(owner: ObjectIdentifier(self), phone: number)
//
//        registerPhone.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: registerPhone)
    }
    
    func registerWith(phone: String, bvn: String, dateBirth: String) {
        print("\(phone) \(bvn) \(dateBirth)")
        
        dismissNavBarActivity()
    }
    
    func goToNext() {
        self.view.isUserInteractionEnabled = false
        // Image on top
        self.stepImageView.image = #imageLiteral(resourceName: "step_succes")
        
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.dismissNavBarActivity()
            
            self.performSegue(withIdentifier: "StepTwo", sender: self)
        }
    }
}

// MARK: UITextFieldDelegate
extension StepOneSignUpViewController: UITextFieldDelegate {
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
