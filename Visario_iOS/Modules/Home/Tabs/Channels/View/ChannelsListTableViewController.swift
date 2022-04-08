//
//  ChannelsListTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

final class ChannelsListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel = ChannelsViewModel()
    private var searchedChannelsTableViewController: SearchedChannelsTableViewController?
    var websocketCompletion: () -> Void = { }
    
    // MARK: - UI Elements
    
    private lazy var channelsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchAllChannels), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchedChannelsTableViewController)
        return searchController
    }()
    
    private lazy var createChannelBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "Create"
        barButtonItem.style = .plain
        barButtonItem.target = self
        barButtonItem.action = #selector(createBarButtonTapped)
        return barButtonItem
    }()
    
    private lazy var spacer: UIBarButtonItem = {
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceBarItem.width = 16
        return spaceBarItem
    }()
    
    private lazy var botBarButton: UIBarButtonItem = {
        let botButton = UIButton()
        botButton.setImage(UIImage(named: "bot"), for: .normal)
        botButton.addTarget(self, action: #selector(goToChatBotRoom), for: .touchUpInside)
        botButton.snp.makeConstraints { $0.width.height.equalTo(30) }
        return UIBarButtonItem(customView: botButton)
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        setupNavigationBar()
        setupTableView()
        setupWebSocket()
        setupObservers()
        getData()
        getCtatBotMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ConnectivityManager.shared.addListener(listener: self)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        view.hideHUD()
        ConnectivityManager.shared.removeListener(listener: self)
    }
    
    private func setupWebSocket() {
        channelsViewModel.getWebSocketSignedURL { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let webSocketModel):
                WebSocketManager.shared.setupWebSocket(with: webSocketModel.message)
                self.connectToWebSocket()
            case .failure(let error):
                print("WebSocket:", error.localizedDescription)
            }
        }
    }
    
    private func connectToWebSocket() {
        WebSocketManager.shared.connectToWebSocket { [weak self] amazonMessageModel in
            guard let self = self else { return }
            switch amazonMessageModel {
            case .success(let message):
                self.channelsViewModel.updateMessage(message: message) {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.websocketCompletion()
                    }
                }
            case .failure(let error):
                print("WebSocket:", error.localizedDescription)
            }
        }
    }
    
    private func setupObservers() {
        suspendAppStateCompletion = { [weak self] appState in
            guard let self = self else { return }
            switch appState {
            case .foreground:
                self.setupWebSocket()
                self.getData()
            case .background:
                break
            }
        }
    }
    
    private func getData() {
        view.showRotationHUD()
        getAllChannels()
    }
    
    private func getAllChannels() {
        channelsViewModel.getAllChannels { [weak self] response in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.channelsRefreshControl.endRefreshing()
                switch response {
                case .success:
                    self.view.hideHUD()
                    self.tableView.reloadData()
                    self.websocketCompletion()
                case .failure:
                    self.view.showFailedHUD()
                }
            }
        }
    }
    
    private func getCtatBotMessages() {
        channelsViewModel.getChatBotMessages { response in
            
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = TabItem.chats.title
        navigationItem.rightBarButtonItems = [createChannelBarButton, spacer, botBarButton]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchController() {
        guard let navigationController = navigationController else { return }
        searchedChannelsTableViewController = SearchedChannelsTableViewController(viewModel: channelsViewModel, delegate: self, navigationController: navigationController)
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
    
    // MARK: - Actions
    
    @objc private func createBarButtonTapped() {
        let createChannelTableViewController = CreateChannelTableViewController(viewModel: channelsViewModel, channelsListController: self)
        navigationController?.pushViewController(createChannelTableViewController, animated: true)
    }
    
    @objc private func goToChatBotRoom() {
        let chatBotRoomViewController = ChatBotRoomViewController(viewModel: channelsViewModel)
        navigationController?.pushViewController(chatBotRoomViewController, animated: true)
    }
    
    @objc func fetchAllChannels() {
        getAllChannels()
    }
}

// MARK: - UITableViewDelegate

extension ChannelsListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channelsViewModel.channels[indexPath.row]
        let chatViewController = ChatViewController(viewModel: channelsViewModel, channelArn: channel.channelArn, channelName: channel.name, delegate: self)
        chatViewController.navigationItem.title = channel.name
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

// MARK: - NetworkConnectionStatusListener

extension ChannelsListTableViewController: NetworkConnectionStatusListener {
    
    func networkStatusDidChange(status: NetworkConnectionStatus) {
        switch status {
        case .online:
            connectToWebSocket()
        case .offline:
            break
        }
    }
    
}
