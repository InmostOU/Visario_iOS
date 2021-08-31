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
    private let channelsListTableViewController: ChannelsListTableViewController
    
    // MARK: - Lifecycle
    
    init(viewModel: ChannelsViewModel, channelsListController: ChannelsListTableViewController) {
        self.channelsViewModel = viewModel
        self.channelsListTableViewController = channelsListController
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
    
    private func showAddToChannelAlertSheet(by channelArn: String) {
        let alert = UIAlertController(title: "Add To Channel", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add to channel", style: .destructive) { [ unowned self] action in
            self.addToChannel(by: channelArn)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addToChannel(by channelArn: String) {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        
        view.showRotationHUD()
        
        channelsViewModel.addMemberToChannel(channelArn: channelArn, memberArn: userProfile.userArn) { response in
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
                self.channelsListTableViewController.fetchAllChannels()
            case .failure(let error):
                self.view.hideHUD()
                self.showError(error: error)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchedChannelsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedChannel = channelsViewModel.findedChannels[indexPath.row]
        showAddToChannelAlertSheet(by: selectedChannel.channelArn)
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

        channelsViewModel.findChannel(name: text) { response in
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

// MARK: - BaseView

extension SearchedChannelsTableViewController: BaseView {
    
}
