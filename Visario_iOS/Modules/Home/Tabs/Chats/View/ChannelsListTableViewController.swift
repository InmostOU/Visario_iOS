//
//  ChannelsListTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

final class ChannelsListTableViewController: UITableViewController {
    
    // MARK: - Preperties
    
    private let channelsViewModel = ChannelsViewModel()
    private var searchedChannelsTableViewController: SearchedChannelsTableViewController?
    
    // MARK: - UI Elements
    
    private lazy var channelsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchAllChannels), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchedChannelsTableViewController)
        return searchController
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.showRotationHUD()
        setupSearchController()
        setupNavigationBar()
        setupTableView()
        getAllChannels()
    }
    
    private func getAllChannels() {
        channelsViewModel.getAllChannels { response in
            self.channelsRefreshControl.endRefreshing()
            switch response {
            case .success(_):
                self.view.hideHUD()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.view.hideHUD()
                self.showError(error: error)
            }
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = TabItem.chats.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createBarButtonTapped))
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchController() {
        searchedChannelsTableViewController = SearchedChannelsTableViewController(viewModel: channelsViewModel, channelsListController: self)
        searchController.searchResultsUpdater = searchedChannelsTableViewController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search channels"
        //searchController.searchBar.delegate = self
        //searchController.searchBar.searchTextField.delegate = self
    }
    
    private func setupTableView() {
        tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = channelsRefreshControl
    }
    
    @objc private func createBarButtonTapped() {
        let createChannelTableViewController = CreateChannelTableViewController(viewModel: channelsViewModel, channelsListController: self)
        navigationController?.pushViewController(createChannelTableViewController, animated: true)
    }
    
    @objc func fetchAllChannels() {
        getAllChannels()
    }
}

// MARK: - UITableViewDelegate

extension ChannelsListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channelsViewModel.channels[indexPath.row]
        let chatViewController = ChatViewController(viewModel: channelsViewModel, channel: channel)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension ChannelsListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsViewModel.channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.identifier, for: indexPath) as! ChannelTableViewCell
        
        let channel = channelsViewModel.channels[indexPath.row]
        cell.fill(with: channel)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let leaveAction = UIContextualAction(style: .destructive, title: "Leave") { (_, _, handler) in
            self.view.showRotationHUD()
            let channelArn = self.channelsViewModel.channels[indexPath.row].channelArn
            self.channelsViewModel.leaveChannel(channelArn: channelArn) { response in
                switch response {
                case .success(_):
                    self.view.showSuccessHUD()
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    self.view.hideHUD()
                    self.showError(error: error)
                    print(error)
                }
                handler(true)
            }
        }
        leaveAction.image = UIImage(systemName: "person.fill.xmark")
        let swipeActions = UISwipeActionsConfiguration(actions: [leaveAction])
        return swipeActions
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: BaseView

extension ChannelsListTableViewController: BaseView {
    
}

