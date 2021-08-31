//
//  ProfileViewModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import UIKit

final class ProfileViewModel {
    
    // MARK: - Properties
    
    private(set) var profile: ContactModel
    weak var view: (BaseView & UIViewController)?
    
    // MARK: - Init
    
    init(profile: ContactModel) {
        self.profile = profile
    }
}
