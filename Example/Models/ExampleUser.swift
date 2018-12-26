//
//  ExampleUser.swift
//  Example
//
//  Created by Anton Zhdanov on 7/11/18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import Foundation

public struct ExampleUser: Codable {
    let country: String
    let dateBirth: String
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
    var deactivated: Bool
    
    init(country: String,
         dateBirth: String,
         email: String,
         firstName: String,
         lastName: String,
         phoneNumber: String,
         deactivated: Bool) {
        self.country = country
        self.dateBirth = dateBirth
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.deactivated = deactivated
    }
}
