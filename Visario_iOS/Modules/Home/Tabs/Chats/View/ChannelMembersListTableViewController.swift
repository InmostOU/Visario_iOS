//
//  ChannelMembersListTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 25.08.2021.
//

import UIKit

final class ChannelMembersListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let channel: ChannelModel
    //private let contactsViewModel = ContactsViewModel()
    
    // MARK: - Lifecycle
    
    init(model: ChannelsViewModel, channel: ChannelModel) {
        self.channelsViewModel = model
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        //self.navigationItem.title = "Add member"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMemberToChannel))
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    @objc private func addMemberToChannel() {
        let addMembersToChannelTableViewController = AddMembersToChannelTableViewController(model: channelsViewModel, channel: channel)
        navigationController?.pushViewController(addMembersToChannelTableViewController, animated: true)
    }
}
