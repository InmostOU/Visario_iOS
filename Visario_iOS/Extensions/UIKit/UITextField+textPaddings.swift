//
//  UITextField+textPaddings.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import UIKit

extension UITextField {
    
    func innerPaddings(left: CGFloat, right: CGFloat){
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: frame.size.height))
        self.leftView = leftView
        self.leftViewMode = .always
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: frame.size.height))
        self.rightView = rightView
        self.rightViewMode = .always
    }
}
