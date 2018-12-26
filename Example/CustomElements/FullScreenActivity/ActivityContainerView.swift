//
//  ActivityContainerView.swift
//  Example
//
//  Created by Anton Zhdanov on 6/5/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

final class ActivityContainerView: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    deinit {        
        activityIndicator.stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ActivityContainerView", owner: self, options: nil)
        
        contentView.alpha = 0
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 1
        }
    }
    
    public func startActivityAnimation() {
        activityIndicator.startAnimating()
    }
}
