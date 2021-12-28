//
//  ChannelSelectionViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 14.09.2021.
//

import UIKit

final class ChannelSelectionViewController: UIViewController {
    
    private let channelsViewModel = ChannelsViewModel()
    private let channelSelectionViewModel = ChannelSelectionViewModel()
    private let messagesConverter = MessagesConverter()
    
    private lazy var channelsTableView: UITableView = {
        let channelsTableView = UITableView(frame: .zero, style: .plain)
        channelsTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        channelsTableView.dataSource = self
        channelsTableView.delegate = self
        return channelsTableView
    }()
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Send invite to this meeting"
        textLabel.font = .boldSystemFont(ofSize: 16)
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureView()
        confiugreLayout()
        
        channelsViewModel.view = self
        channelSelectionViewModel.view = self
        
        getAllChannels()
    }
    
    private func presentMeetingVC(meetingId: String) {
        let vm = MeetingViewModel(meetingId: meetingId)
        let vc = MeetingViewController(viewModel: vm)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func getAllChannels() {
        activityIndicator.startAnimating()
        channelsViewModel.getAllChannels { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.channelsTableView.reloadData()
                }
            case .failure(let error):
                self.showError(error: error)
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func configureView() {
        view.addSubview(textLabel)
        view.addSubview(channelsTableView)
        view.addSubview(activityIndicator)
    }
    
    private func confiugreLayout() {
        textLabel.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
        }
        
        channelsTableView.snp.makeConstraints {
            $0.top.equalTo(textLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

extension ChannelSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        channelsViewModel.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier) else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = channelsViewModel.channels[indexPath.row].name
        return cell
    }
}

extension ChannelSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channelArn = channelsViewModel.channels[indexPath.row].channelArn
        
        channelSelectionViewModel.createMeetingAndGetInviteMessage(channelArn: channelArn) { [weak self] message, meetingId in
            guard let self = self else { return }
            var successCount = 0
            
            self.channelsViewModel.sendMessage(message: message) { result in
                switch result {
                case .success(()):
                    successCount += 1
                    
                    if successCount == 2 {
                        print("invite sent")
                        self.presentMeetingVC(meetingId: meetingId)
                    }
                    
                case .failure(let error):
                    self.showError(error: error)
                }
            }
        }
    }
}

