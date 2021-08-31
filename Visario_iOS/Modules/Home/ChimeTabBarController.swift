//
//  ChimeTabBarController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

final class ChimeTabBarController: UITabBarController {
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTabs()
    }
    
    private func addTabs() {
        let viewControllers = instancesViewControllers()
        setViewControllers(viewControllers, animated: false)
    }
    
    private func instancesViewControllers() -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        
        for tab in TabItem.allCases {
            let newTabBarItem = UITabBarItem()
            newTabBarItem.image = tab.icon
            newTabBarItem.title = tab.title
            
            let viewController = tab.viewController
            viewController.view.backgroundColor = .white
            viewController.tabBarItem = newTabBarItem
            
            viewControllers.append(viewController)
        }
        return viewControllers
    }
}
