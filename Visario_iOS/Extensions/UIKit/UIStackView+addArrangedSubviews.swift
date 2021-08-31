//
//  UIStackView+addArrangeSubviews.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
}
