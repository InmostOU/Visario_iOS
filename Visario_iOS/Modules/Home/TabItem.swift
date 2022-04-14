//
//  TabItem.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case channels = "Channels"
    case meetings = "Meetings"
    case contacts = "Contacts"
    case settings = "Settings"
    
    var viewController: UIViewController {
        switch self {
        case .channels:
            return UINavigationController(rootViewController: ChannelsListTableViewController())
        case .meetings:
            return UINavigationController(rootViewController: StartMeetingViewController())
        case .contacts:
            return UINavigationController(rootViewController: ContactsListTableViewController())
        case .settings:
            return UINavigationController(rootViewController: SettingsViewController())
        }
    }
    
    var icon: UIImage {
        switch self {
        case .channels:
            return UIImage(systemName: "message.fill")!
        case .meetings:
            return UIImage(systemName: "phone.fill")!
        case .contacts:
            return UIImage(systemName: "person.2.fill")!
        case .settings:
            return UIImage(systemName: "gearshape.fill")!
        }
    }
    
    var title: String {
        return rawValue.capitalized
    }
}
