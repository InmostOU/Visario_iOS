//
//  UIView+ProgressHUD.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 10.08.2021.
//

import UIKit
import ProgressHUD

extension UIView {
    
    func showRotationHUD() {
        ProgressHUD.show()
        ProgressHUD.animationType = .circleRotateChase
        ProgressHUD.colorAnimation = .systemBlue
    }
    
    func showHUD(icon: AlertIcon) {
        ProgressHUD.show(icon: icon)
    }
    
    func showSuccessHUD() {
        ProgressHUD.showSucceed()
        ProgressHUD.colorAnimation = .systemGreen
    }
    
    func showFailedHUD() {
        ProgressHUD.showFailed()
        ProgressHUD.colorAnimation = .systemRed
    }
    
    func hideHUD() {
        ProgressHUD.dismiss()
    }
    
}
