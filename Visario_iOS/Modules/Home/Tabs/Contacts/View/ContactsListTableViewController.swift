//
//  ContactsListTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

class ContactsListTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    private let contactsViewModel = ContactsViewModel()
    private let usersActivityService = StompClient.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsViewModel.view = self
        usersActivityService.delegate = self
        
        setupNavigationBar()
        setupTableView()
        getAllContacts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.hideHUD()
    }
    
    private func setBackgroundView() {
        if contactsViewModel.allContacts.isEmpty {
            let backgroundView = TableBackgroundView()
            backgroundView.fill(with: "No contacts")
            tableView.backgroundView = backgroundView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func getAllContacts() {
        view.showRotationHUD()
        contactsViewModel.getAllContacts { [weak self] response in
            guard let self = self else { return }
            self.setBackgroundView()
            switch response {
            case .success(_):
                self.view.hideHUD()
                self.tableView.reloadData()
                self.getContactsActivityStatus()
            case .failure(let error):
                self.view.showFailedHUD()
                print(error)
            }
        }
    }
    
    private func getContactsActivityStatus() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        contactsViewModel.getContactsActivityStatus(by: userProfile.userArn) { [weak self] response in
            guard let self = self else { return }
            self.setBackgroundView()
            switch response {
            case .success(_):
                self.view.hideHUD()
                self.tableView.reloadData()
            case .failure(let error):
                self.view.showFailedHUD()
                print(error)
            }
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = TabItem.contacts.title
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUserButtonTapped))
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    private func setupTableView() {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
    @objc private func addUserButtonTapped(_ sender: UIBarButtonItem) {
        let addContactsViewController = AddContactsTableViewController(model: contactsViewModel, delegate: self)
        contactsViewModel.removeAllSearchedContacts()
        navigationController?.pushViewController(addContactsViewController, animated: true)
    }
    
    private func deleteContact(by indexPath: IndexPath) {
        contactsViewModel.deleteContact(at: indexPath.row) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
                self.setBackgroundView()
            case .failure(let error):
                self.view.showFailedHUD()
                print(error)
            }
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDelegate

extension ContactsListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactsViewModel.allContacts[indexPath.row]
        contactsViewModel.showContactInfo(with: contact)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - UITableViewDataSource

extension ContactsListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsViewModel.allContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as! ContactTableViewCell
        
        let contact = contactsViewModel.allContacts[indexPath.row]
        cell.fill(with: contact)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [unowned self] (_, _, _) in
            self.deleteContact(by: indexPath)
        }
        deleteAction.image = UIImage(systemName: "person.fill.badge.minus")
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - StompClientDelegate

extension ContactsListTableViewController: StompClientDelegate {
    
    func userActivity(user: ContactModel) {
        contactsViewModel.setActivityStatus(of: user)
        tableView.reloadData()
    }
    
}
