//
//  PINKeyboardView.swift
//  Example
//
//  Created by Anton Zhdanov on 3/2/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

final class PINKeyboardView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var forgotPINView: UIView!
    
    @IBOutlet private weak var numOneButton: UIButton!
    @IBOutlet private weak var numTwoButton: UIButton!
    @IBOutlet private weak var numThreeButton: UIButton!
    @IBOutlet private weak var numFourButton: UIButton!
    @IBOutlet private weak var numFiveButton: UIButton!
    @IBOutlet private weak var numSixButton: UIButton!
    @IBOutlet private weak var numSevenButton: UIButton!
    @IBOutlet private weak var numEightButton: UIButton!
    @IBOutlet private weak var numNineButton: UIButton!
    @IBOutlet private weak var numZeroButton: UIButton!
    
    @IBOutlet private weak var indicatorOneImageView: UIImageView!
    @IBOutlet private weak var indicatorTwoImageView: UIImageView!
    @IBOutlet private weak var indicatorThreeImageView: UIImageView!
    @IBOutlet private weak var indicatorFourImageView: UIImageView!
    
    var numButtonPressed: ((String?) -> ())?
    var deleteButtonPressed: (() -> ())?
    var forgotButtonPressed: (() -> ())?
    var signInButtonPressed: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PINKeyboardView", owner: self, options: nil)
        addSubview(contentView)
        forgotPINView.isHidden = true
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backView.backgroundColor = UIColor.clear
    }
    
    public func changeIndicatorsState(isFirstIsOn: Bool, isSecondIsOn: Bool, isThirdIsOn: Bool, isFourthIsOn: Bool) {
        DispatchQueue.main.async {
            self.indicatorOneImageView.image = isFirstIsOn ? #imageLiteral(resourceName: "pin_filled") : #imageLiteral(resourceName: "pin_not_filled")
            self.indicatorTwoImageView.image = isSecondIsOn ? #imageLiteral(resourceName: "pin_filled") : #imageLiteral(resourceName: "pin_not_filled")
            self.indicatorThreeImageView.image = isThirdIsOn ? #imageLiteral(resourceName: "pin_filled") : #imageLiteral(resourceName: "pin_not_filled")
            self.indicatorFourImageView.image = isFourthIsOn ? #imageLiteral(resourceName: "pin_filled") : #imageLiteral(resourceName: "pin_not_filled")
        }
    }
    
    // TODO: search in subviews
    public func switchKeyboardButtons(areEnabled: Bool) {
        self.numOneButton.isEnabled = areEnabled
        self.numTwoButton.isEnabled = areEnabled
        self.numThreeButton.isEnabled = areEnabled
        self.numFourButton.isEnabled = areEnabled
        self.numFiveButton.isEnabled = areEnabled
        self.numSixButton.isEnabled = areEnabled
        self.numSevenButton.isEnabled = areEnabled
        self.numEightButton.isEnabled = areEnabled
        self.numNineButton.isEnabled = areEnabled
        self.numZeroButton.isEnabled = areEnabled
    }
}

private extension PINKeyboardView {
    @IBAction func catchButtonAction(_ sender: UIButton) {
        guard let someInput = sender.titleLabel?.text else {
            return
        }

        numButtonPressed?(someInput)
    }
    
    @IBAction func eraseButtonPressed(_ sender: Any) {
        deleteButtonPressed?()
    }
    
    @IBAction func forgotButtonPressed(_ sender: Any) {
        forgotButtonPressed?()
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        signInButtonPressed?()
    }
}
