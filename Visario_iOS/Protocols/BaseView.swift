//
//  BaseView.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 05.08.2021.
//

import UIKit

protocol BaseView: AnyObject {
    func showAlert(title: String, message: String, completion: (() -> Void)?)
    func showError(error: Error)
}

extension BaseView where Self: UIViewController {
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    func showError(error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
}

extension UIViewController: BaseView {
    
}
