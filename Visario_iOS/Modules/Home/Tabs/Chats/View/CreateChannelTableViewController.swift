//
//  CreateChannelTableViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 16.08.2021.
//

import UIKit

final class CreateChannelTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    enum Section: String {
        case name = "Name"
        case description = "Description"
        case privacy = "Privacy"
        
        var index: Int {
            switch self {
            case .name:
                return 0
            case .description:
                return 1
            case .privacy:
                return 2
            }
        }
        
        enum RowType {
            case privacy
            case restriction
            
            var index: Int {
                switch self {
                case .privacy:
                    return 0
                case .restriction:
                    return 1
                }
            }
        }
    }
    
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
        
        setupNavigationBar()
        setupTableView()
        createSections()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Create Channel"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButtonTapped))
    }
    
    private func setupTableView() {
        tableView.register(ChannelSetNameTableViewCell.self, forCellReuseIdentifier: ChannelSetNameTableViewCell.identifier)
        tableView.register(ChannelDescriptionTableViewCell.self, forCellReuseIdentifier: ChannelDescriptionTableViewCell.identifier)
        tableView.register(ChannelPrivacyTableViewCell.self, forCellReuseIdentifier: ChannelPrivacyTableViewCell.identifier)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.alwaysBounceVertical = false
        tableView.tableFooterView = UIView()
    }
    
    private func createSections() {
        channelsViewModel.createSections()
    }
    
    @objc private func doneBarButtonTapped() {
        guard !channelsViewModel.newChannel.name.isEmptyOrWhitespace() else {
            showAlert(title: "Set channel name!", message: "")
            return
        }
        
        view.showRotationHUD()
        
        channelsViewModel.createChannel { response in
            self.view.hideHUD()
            switch response {
            case .success(_):
                self.channelsViewModel.newChannel = ChannelModel.placeholder
                self.channelsListTableViewController.fetchAllChannels()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CreateChannelTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray5
        
        let rect = CGRect(x: 16, y: 22, width: tableView.bounds.width, height: tableView.bounds.height)
        let sectionLabel = UILabel(frame: rect)
        sectionLabel.font = UIFont(name: "Helvetica", size: 12)
        sectionLabel.textColor = .gray
        
        switch section {
        case Section.name.index:
            sectionLabel.text = Section.name.rawValue.uppercased()
        case Section.description.index:
            sectionLabel.text = Section.description.rawValue.uppercased()
        case Section.privacy.index:
            sectionLabel.text = Section.privacy.rawValue.uppercased()
        default:
            break
        }
        
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - UITableViewDataSource

extension CreateChannelTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return channelsViewModel.channelsSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsViewModel.channelsSections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionItems = channelsViewModel.channelsSections[indexPath.section].items
        let sectionDataSource = sectionItems[indexPath.row]
        
        switch sectionDataSource {
        case .name(let name):
            let cell = tableView.dequeueReusableCell(withIdentifier: ChannelSetNameTableViewCell.identifier) as! ChannelSetNameTableViewCell
            cell.selectionStyle = .none
            cell.fill(with: name)
            cell.delegate = self
            return cell
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: ChannelDescriptionTableViewCell.identifier) as! ChannelDescriptionTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case .privacy(let privacyModel):
            let cell = tableView.dequeueReusableCell(withIdentifier: ChannelPrivacyTableViewCell.identifier) as! ChannelPrivacyTableViewCell
            cell.selectionStyle = .none
            cell.fill(with: privacyModel, for: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.name.index:
            return Section.name.rawValue
        case Section.privacy.index:
            return Section.privacy.rawValue
        default:
            return ""
        }
    }
}

// MARK: - CreateChannelCellDelegate

extension CreateChannelTableViewController: CreateChannelCellDelegate {
    
    func setChannelName(name: String) {
        channelsViewModel.newChannel.name = name
    }
    
    func setChannelDescription(description: String) {
        channelsViewModel.newChannel.description = description
    }
    
    func setChannelPrivacy(_ isOn: Bool, for indexPath: IndexPath) {
        switch indexPath.section {
        case Section.privacy.index:
            switch indexPath.row {
            case Section.RowType.privacy.index:
                channelsViewModel.setChannelPrivacy(privacy: isOn ? .private : .public)
                insertRestrictionRow(isOn)
            case Section.RowType.restriction.index:
                channelsViewModel.setChannelRestriction(mode: isOn ? .restricted : .unrestricted)
            default:
                return
            }
        default:
            return
        }
    }
    
    private func insertRestrictionRow(_ isInserting: Bool) {
        let restrictionInexPath = IndexPath(row: 1, section: Section.privacy.index)
        if isInserting {
            tableView.insertRows(at: [restrictionInexPath], with: .top)
        } else {
            tableView.deleteRows(at: [restrictionInexPath], with: .top)
        }
    }
}

// MARK: - BaseView

extension CreateChannelTableViewController: BaseView {
    
}
