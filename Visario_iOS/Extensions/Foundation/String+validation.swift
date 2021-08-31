//
//  String+validation.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 18.08.2021.
//

import Foundation

extension String {
    
    func isValidUserName() -> Bool {
        let userNameRegExp = "[A-Za-z0-9-.]+"
        let userNamePredicate = NSPredicate(format: "SELF MATCHES %@", userNameRegExp)
        return userNamePredicate.evaluate(with: self)
    }

    func isValidEmail() -> Bool {
        let emailRegExp = #"^[a-zA-Z0-9.!#$%&'+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)$"#
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegExp)
        return emailTest.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        let passwordRegExp = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9\\s]).{6,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegExp)
        return passwordPredicate.evaluate(with: self)
    }
    
    func isValidLastFirstName() -> Bool {
        let lastFirstNameRegExp = "[a-zA-Z]+"
        let lastFirstNamePredicate = NSPredicate(format: "SELF MATCHES %@", lastFirstNameRegExp)
        return lastFirstNamePredicate.evaluate(with: self)
    }
    
}
