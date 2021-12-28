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
    private let channelArn: String
    private let delegate: ChannelMembersListTableViewController
    
    // MARK: - Lifecycle
    
    init(model: ChannelsViewModel, channelArn: String, delegate: ChannelMembersListTableViewController) {
        channelsViewModel = model
        self.channelArn = channelArn
        self.delegate = delegate
        super.init(model: contactsViewModel, delegate: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Add member"
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.hideHUD()
    }
    
    private func setupTableView() {
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
    }
    
    private func showAddToChannelAlertSheet(by memberArn: String) {
        let alert = UIAlertController(title: "You can add member to channel", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add to channel", style: .destructive) { [weak self] action in
            guard let self = self else { return }
            self.addMemberToChannel(by: memberArn)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addMemberToChannel(by memberArn: String) {
        view.showRotationHUD()
        channelsViewModel.addMemberToChannel(channelArn: channelArn, memberArn: memberArn) { response in
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
                self.delegate.getChannelMembers()
            case .failure(let error):
                self.view.hideHUD()
                switch error {
                case .errorResponse(let error):
                    self.showAlert(title: error.error.rawValue, message: error.message)
                default:
                    self.showError(error: error)
                }
            }
        }
    }
}

// MARK: - AddContactCellDelegate

extension AddMembersToChannelTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedContact = contactsViewModel.searchedContacts[indexPath.row]
        showAddToChannelAlertSheet(by: selectedContact.userArn)
    }
}

// MARK: - UITableViewDataSource

extension AddMembersToChannelTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as! ContactTableViewCell
        let contact = contactsViewModel.searchedContacts[indexPath.row]
        
        cell.fill(with: contact)
        return cell
    }
}
