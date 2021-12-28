//
//  SearchedChannelsTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 26.08.2021.
//

import UIKit

final class SearchedChannelsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let delegate: ChannelsListTableViewController
    let parentNavigationController: UINavigationController
    var websocketCompletion: () -> Void = { }
    
    // MARK: - Lifecycle
    
    init(viewModel: ChannelsViewModel, delegate: ChannelsListTableViewController, navigationController: UINavigationController) {
        self.channelsViewModel = viewModel
        self.delegate = delegate
        self.parentNavigationController = navigationController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDelegate

extension SearchedChannelsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        parentNavigationController.view.endEditing(true)
        
        let channel = channelsViewModel.findedChannels[indexPath.row]
        let chatViewController = SearchedChannelChatViewController(viewModel: channelsViewModel, channelArn: channel.channelArn, delegate: delegate)
        chatViewController.navigationItem.title = channel.name
        parentNavigationController.pushViewController(chatViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SearchedChannelsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsViewModel.findedChannels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.identifier, for: indexPath) as! ChannelTableViewCell
        let channel = channelsViewModel.findedChannels[indexPath.row]
        
        cell.fill(with: channel)
        return cell
    }
}

// MARK: - UISearchResultUpdating

extension SearchedChannelsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            channelsViewModel.removeAllFindedChannels()
            self.tableView.reloadData()
            return
        }
        view.showRotationHUD()

        channelsViewModel.findChannels(name: text) { response in
            self.view.hideHUD()
            switch response {
            case .success(_):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
