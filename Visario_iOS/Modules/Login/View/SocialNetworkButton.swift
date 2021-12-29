//
//  SocialNetworkButton.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 29.12.2021.
//

import UIKit

final class SocialNetworkButton: UIButton {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        defaultSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func defaultSetup() {
        layer.cornerRadius = 3
        layer.masksToBounds = true
        
        snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }
    
}
