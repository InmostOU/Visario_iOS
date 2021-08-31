//
//  AddMembersToChannelTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 25.08.2021.
//

import UIKit

final class AddMembersToChannelTableViewController: AddContactsTableViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let contactsViewModel = ContactsViewModel()
    private let channel: ChannelModel
    
    // MARK: - Lifecycle
    
    init(model: ChannelsViewModel, channel: ChannelModel) {
        channelsViewModel = model
        self.channel = channel
        super.init(model: contactsViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Add member"
    }
}

// MARK: - AddContactCellDelegate

extension AddMembersToChannelTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedContact = contactsViewModel.searchedContacts[indexPath.row]
        
        channelsViewModel.addMemberToChannel(channelArn: channel.channelArn, memberArn: selectedContact.userArn) { response in
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
            case .failure(_):
                self.view.showFailedHUD()
            }
        }
    }
}
