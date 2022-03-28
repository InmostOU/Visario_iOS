//
//  ChannelMembersListTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 25.08.2021.
//

import UIKit

final class ChannelMembersListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let contactsConverter = ContactsConverter()
    private let usersActivityService = StompClient.shared
    
    private let channelsViewModel: ChannelsViewModel
    private let channelArn: String
    
    // MARK: UI Elements
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    init(model: ChannelsViewModel, channelArn: String) {
        self.channelsViewModel = model
        self.channelArn = channelArn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersActivityService.delegate = self
        
        clearData()
        setupNavigationBar()
        setupSearchController()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if channelsViewModel.filteredMembers.isEmpty {
            getChannelMembers()
        }
        getChannelMembersActivityStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.hideHUD()
    }
    
    private func clearData() {
        channelsViewModel.removeAllFilteredMembers()
    }
    
    private func setupNavigationBar() {
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMemberToChannel))
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Members"
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter members"
    }
    
    private func setupTableView() {
        tableView.register(ChannelMemberTableViewCell.self, forCellReuseIdentifier: ChannelMemberTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
    func getChannelMembers() {
        view.showRotationHUD()
        channelsViewModel.getChannelMembers(channelArn: channelArn) { [weak self] response in
            guard let self = self else { return }
            self.view.hideHUD()
            switch response {
            case .success:
                self.tableView.reloadData()
                self.getChannelMembersActivityStatus()
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
    
    private func getChannelMembersActivityStatus() {
        channelsViewModel.getChannelMembersActivityStatus(channelArn: channelArn) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                self.getUserContactsActivityStatus()
            case .failure(let error):
                self.view.hideHUD()
                self.tableView.reloadData()
                print(error)
            }
        }
    }
    
    private func getUserContactsActivityStatus() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        channelsViewModel.getContactsActivityStatus(for: userProfile.userArn) { [weak self] response in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.view.hideHUD()
        }
    }
    
    // MARK: - Actions
    
    @objc private func addMemberToChannel() {
        let addMembersToChannelTableViewController = AddMembersToChannelTableViewController(model: channelsViewModel, channelArn: channelArn, delegate: self)
        navigationController?.pushViewController(addMembersToChannelTableViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ChannelMembersListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channelMember = channelsViewModel.filteredMembers[indexPath.row]
        let member = contactsConverter.contactModel(from: channelMember)
        channelsViewModel.showContactInfo(with: member)
    }
}

// MARK: - UITableViewDataSource

extension ChannelMembersListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsViewModel.filteredMembers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelMemberTableViewCell.identifier, for: indexPath) as? ChannelMemberTableViewCell else { return UITableViewCell() }
        let channelMember = channelsViewModel.filteredMembers[indexPath.row]
        
        cell.fill(with: channelMember)
        return cell
    }
}

// MARK: - UISearchResultUpdating

extension ChannelMembersListTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            channelsViewModel.resetMembersFilters()
            tableView.reloadData()
            return
        }
        channelsViewModel.filterMembers(by: query)
        tableView.reloadData()
    }
}

// MARK: - StompClientDelegate

extension ChannelMembersListTableViewController: StompClientDelegate {
    
    func userActivity(user: ContactModel) {
        channelsViewModel.setActivityState(of: user)
        tableView.reloadData()
    }
    
}
