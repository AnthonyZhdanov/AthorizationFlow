//
//  StepThreeSignUpViewController.swift
//  Example
//
//  Created by Anton Zhdanov on 20.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

private struct CountryItem {
    let iso: String
    let code: String
    let name: String
    
    init(iso: String, code: String, name: String) {
        self.iso = iso
        self.code = code
        self.name = name
    }
}

final class StepThreeSignUpViewController: UIViewController {

    @IBOutlet private weak var theScrollView: UIScrollView!
    @IBOutlet private weak var nameTextField: HintTextField!
    @IBOutlet private weak var lastNameTextField: HintTextField!
    @IBOutlet private weak var dateTextField: HintTextField!
    @IBOutlet private weak var countryTextField: HintTextField!
    @IBOutlet private weak var emailTextField: HintTextField!
    @IBOutlet private weak var passwordTextField: HintTextField!
    @IBOutlet private weak var stepImageView: UIImageView!
    private var countryPicker: UIPickerView!
    private var countriesList: [CountryItem] = []
    private var phoneNumber: String?
    private let infoMessageText = "Password should contain at least:\n8 characters\none letter\none capital letter\none number;\nLimitation:\nno consecutive characters\n not exceed 30 symbols "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCountriesList()
        addPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.stepImageView.image = #imageLiteral(resourceName: "step")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        
//        Dispatcher.shared.cancelAllRequests(owner: ObjectIdentifier(self))
    }
    
    public func setPhone(number: String) {
        self.phoneNumber = number
    }
}

extension StepThreeSignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countriesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countriesList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard !countriesList.isEmpty else { return }
        
        countryTextField.text = countriesList[row].name
        
//        countryTextField.showHint = true
    }
}

private extension StepThreeSignUpViewController {
    // MARK: - Private
    func addPickers() {
        dateTextField.addOwnDatePicker(value: nil, format: "dd/MM/yyyy", limited: true)
//        countryPicker = UIPickerView()
//        countryPicker.delegate = self
//        countryPicker.dataSource = self
//        countryTextField.inputView = countryPicker
    }
    
    func getCountriesList() {
        displayNavBarActivity()
        
        getCountriesList { [unowned self] (error, success) in
            self.dismissNavBarActivity()
            if success {
                print("Success")
//                DispatchQueue.main.async {
//                    self.countryPicker.reloadAllComponents()
//                }
            }
        }
    }
    
    // MARK: - Handle Actions
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let (status, message) = validate()
        if status {
            if let name = nameTextField.text, let lastName = lastNameTextField.text, let dateBirth = dateTextField.text, let country = countryTextField.text, let email = emailTextField.text, let phoneNumber = phoneNumber, let password = passwordTextField.text, password.isSufficientComplex() {
                
                var sendData: [String: Any] = [:]
                displayNavBarActivity()
                
                sendData["firstName"] = name
                sendData["lastName"] = lastName
                sendData["dateBirth"] = dateBirth.convertDateFormater(fromFormat: "dd/MM/yyyy", toFormat: "yyyy-MM-dd")
                sendData["country"] = country//countriesList.first(where: {$0.name == country} )?.iso
                sendData["email"] = email
                sendData["phoneNumber"] = phoneNumber
                sendData["password"] = password
                
                registerWith(sendData: sendData)
            } else {
                self.showAllertiWith(message: infoMessageText, textFieldToBecomeResponder: nil)
            }
        } else if let message = message {
            self.showAllertiWith(message: message, textFieldToBecomeResponder: nil)
        }
    }
    
    // MARK: - Switch Secure Input
    @IBAction func secureEntryButtonPressed(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        
        let stateImage = passwordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "visibility_off") : #imageLiteral(resourceName: "visibility_on")
        
        DispatchQueue.main.async {
            sender.setBackgroundImage(stateImage, for: .normal)
        }
    }
    
    // MARK: - Requests
    func registerWith(sendData: [String: Any]) {
        tryToRegisterUserWith(parameters: sendData) { [unowned self] (error, success, message) in
            if success {
                self.goToNext()
            }
            else {
                self.dismissNavBarActivity()
                
                self.showAllertiWith(message: message ?? error?.localizedDescription ?? "Something Went Wrong", textFieldToBecomeResponder: nil)
            }
        }
    }
    
    func getCountriesList(resultBlock: @escaping (Error?, Bool) -> ()) {
//        let getCountriesList = CountriesListRequest.init(owner: ObjectIdentifier(self))
//
//        getCountriesList.completion = { [unowned self] request, error in
//            guard error == nil else {
//                resultBlock(error, false)
//
//                return
//            }
//
//            if let response = request.response as? CountriesListRequest.CountriesListResponse {
//                for country in response.countriesList {
//                    if let iso = country["iso"], let code = country["code"], let name = country["name"] {
//                        self.countriesList.append(CountryItem.init(iso: iso, code: code, name: name))
//                    }
//                }
//
                resultBlock(nil, true)
//            }
//        }
//
//        Dispatcher.shared.processRequest(request: getCountriesList)
    }
    
    func tryToRegisterUserWith(parameters: [String: Any], resultBlock: @escaping (Error?, Bool, String?) -> ()) {
//        let registerUser = RegisterUserRequest.init(owner: ObjectIdentifier(self), params: parameters)
//
//        registerUser.completion = { request, error in
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
//        Dispatcher.shared.processRequest(request: registerUser)
    }
    
    // MARK: - Redirect to next
    func goToNext() {
        self.stepImageView.image = #imageLiteral(resourceName: "step_succes")
        let message = "To proceed, you need to verify your email address. Please check a verification link we've sent to your email address."
        let alertView = UIAlertController(title: "Thank you for joining us!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "NEXT", style: .default) { [unowned self] (alertView: UIAlertAction) in
            self.performSegue(withIdentifier: "AddPIN", sender: self)
        }
        
        alertView.addAction(okAction)
        
        if presentedViewController == nil {
            self.present(alertView, animated: true, completion: nil)
        }
        
        self.dismissNavBarActivity()
    }
}
