//
//  Constants.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 05.08.2021.
//

import Foundation

// Global Constants for use in the project

enum Constants {
    
    static let baseURL = "http://18.193.6.59:8081"
    static let authURL = baseURL + "/auth"
    static let meetingPath = "/meeting/getMeeting?meetingId="
    static let meetingURL = baseURL + meetingPath
    static let usersActivityBaseURL = "http://18.193.6.59:9010/activity"
    
    static let loginPath = "/login"
    static let registerPath = "/register"
    static let changePasswordPath = "/changePassword"
    static let forgotPasswordPath = "/forgot-password"
    
    static let privacySettings = ["Only me", "Everyone", "Only contacts"]
}
