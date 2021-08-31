//
//  UIApplication+window.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

extension UIApplication {
    
    var window: UIWindow? {
        guard let scene = connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else { return nil }
        return window
    }
}
