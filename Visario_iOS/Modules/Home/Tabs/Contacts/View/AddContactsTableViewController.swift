//
//  AddContactsTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import UIKit

class AddContactsTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    private let contactsViewModel: ContactsViewModel
    private let delegate: ContactsListTableViewController?
    
    init(model: ContactsViewModel, delegate: ContactsListTableViewController?) {
        contactsViewModel = model
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupSearchController()
        setBackgroundView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Add Contact"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupTableView() {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(AddContactTableViewCell.self, forCellReuseIdentifier: AddContactTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contacts"
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    private func setBackgroundView() {
        if contactsViewModel.searchedContacts.isEmpty {
            let backgroundView = TableBackgroundView()
            backgroundView.fill(with: "No contacts")
            tableView.backgroundView = backgroundView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func getContactsActivityStatus() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        contactsViewModel.getSearchedContactsActivityStatus(by: userProfile.userArn) { [weak self] response in
            guard let self = self else { return }
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
}

// MARK: - UITableViewDelegate

extension AddContactsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.resignFirstResponder()
        let contact = contactsViewModel.searchedContacts[indexPath.row]
        contactsViewModel.showContactInfo(with: contact)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - UITableViewDataSource

extension AddContactsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsViewModel.searchedContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddContactTableViewCell.identifier, for: indexPath) as! AddContactTableViewCell
        
        let contact = contactsViewModel.searchedContacts[indexPath.row]
        
        if contactsViewModel.allContacts.contains(where: { $0.username == contact.username }) {
            cell.setContainsContactIcon()
        }
        
        cell.fill(with: contact)
        cell.delegate = self
        return cell
    }
}

// MARK: - UISearchResultUpdating

extension AddContactsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            contactsViewModel.removeAllSearchedContacts()
            tableView.reloadData()
            setBackgroundView()
            return
        }
        view.showRotationHUD()
        
        contactsViewModel.searchContacts(by: query) { [weak self] response in
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
}

// MARK: - AddContactCellDelegate

extension AddContactsTableViewController: AddContactCellDelegate {
    
    func add(contact: ContactModel) {
        contactsViewModel.addContact(contact: contact) { result in
            switch result {
            case .success(_):
                self.tableView.reloadData()
                self.view.showSuccessHUD()
                self.delegate?.getAllContacts()
            case .failure(let error):
                self.view.showFailedHUD()
                print(error)
            }
        }
        
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension AddContactsTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        contactsViewModel.removeAllSearchedContacts()
        tableView.reloadData()
        view.hideHUD()
        setBackgroundView()
    }
}

// MARK: - UITextFieldDelegate

extension AddContactsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
