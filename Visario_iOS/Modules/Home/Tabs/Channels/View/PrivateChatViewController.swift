//
//  PrivateChatViewController.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 20.09.2021.
//

import MessageKit

final class PrivateChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    
    private let navBarProfileImageWidth: CGFloat = 40.0
    private let onlineStateCircleViewWidth: CGFloat = 12.0
//    private let channelsViewModel: ChannelsViewModel
//    private let channelArn: String
//    private var sender: Sender!
//    private let delegate: ChannelsListTableViewController
//
    // MARK: - UI Elements

    private lazy var customTitleView: UIView = {
        guard let navigationController = navigationController else { return UIView() }
        let viewWidth = navigationController.navigationBar.frame.width / 1.5
        let viewHeight = navigationController.navigationBar.frame.height
        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        let view = UIView(frame: frame)
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let personImage = UIImage(named: "profile-icon")
        let imageView = UIImageView(image: personImage)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = navBarProfileImageWidth / 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var profileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Elon Musk"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private lazy var profileStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Last seen yesterday 6:22 PM"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var onlineStateCircleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = onlineStateCircleViewWidth / 2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .systemGreen
        return view
    }()
    
    private lazy var moreBarButton: UIBarButtonItem = {
        let moreButton = UIButton()
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.addTarget(self, action: #selector(moreBarButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: moreButton)
        return barButton
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
//    // MARK: - Lifecycle
//
//    init(viewModel: ChannelsViewModel, channelArn: String, delegate: ChannelsListTableViewController) {
//        self.channelsViewModel = viewModel
//        self.channelArn = channelArn
//        self.delegate = delegate
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupSubviews()
        addConstraints()
    }
    
    private func setupNavigationController() {
        navigationItem.rightBarButtonItem = moreBarButton
    }
    
    private func setupSubviews() {
        customTitleView.addSubviews(profileImageView, profileNameLabel, profileStateLabel, onlineStateCircleView)
        navigationItem.titleView = customTitleView
    }
    
    private func addConstraints() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(navBarProfileImageWidth)
        }
        profileNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        profileStateLabel.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom)
            $0.leading.equalTo(profileNameLabel)
        }
        onlineStateCircleView.snp.makeConstraints {
            let divider: CGFloat = 0.75
            $0.width.height.equalTo(onlineStateCircleViewWidth)
            $0.leading.equalTo(navBarProfileImageWidth - onlineStateCircleViewWidth * divider)
            $0.centerY.equalTo(navBarProfileImageWidth * divider)
        }
    }
    
    // MARK: - Actions
    
    @objc private func moreBarButtonTapped() {
        print("ok ok...")
    }
}
