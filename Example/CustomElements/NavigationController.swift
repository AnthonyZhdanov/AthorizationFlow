//
//  NavigationController.swift
//  Example
//
//  Created by Anton Zhdanov on 5/30/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import Foundation

final class NavigationController : UINavigationController {
    private var isInvisible = false
    
    override init(rootViewController : UIViewController) {
        super.init(rootViewController : rootViewController)
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass : navigationBarClass, toolbarClass : toolbarClass)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.navigationBar.setGradientBackground()
    }
}
