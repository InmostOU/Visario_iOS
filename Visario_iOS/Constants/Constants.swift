//
//  Constants.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 05.08.2021.
//

import Foundation

// Global Constants for use in the project

enum Constants {
    static let baseURL = "http://3.129.6.178:8081"
    static let authURL = baseURL + "/auth"
    
    static let loginPath = "/login"
    static let registerPath = "/register"
    
    static let privacySettings = ["Only me", "Everyone", "Only contacts"]
}
