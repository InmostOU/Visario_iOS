//
//  UIView+addSubviews.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func addBottomBorder() {
        let border = UIView()
        border.backgroundColor = .systemGray
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 0.5)
        addSubview(border)
    }
    
}
