//
//  ProfileViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 09.08.2021.
//

import UIKit

final class ProfileViewController: UIViewController, BaseView {
    
    // MARK: - Properties
    
    private let viewModel: ProfileViewModel
    
    private enum Field: Int, CustomStringConvertible {
        case email = 0
        case pfone = 1
        
        var description: String {
            switch self {
            case .email:
                return "email"
            case .pfone:
                return "phone"
            }
        }
    }
    
    // MARK: - UI
    
    private lazy var profileView: ProfileView = {
        let profileView = ProfileView(contact: viewModel.profile, navigationController: navigationController!)
        return profileView
    }()
    
    private lazy var contactInfoTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Init
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    // MARK: - Actions
    
    @objc
    private func editTapped() {
        let editContectProfileViewModel = EditContactProfileViewModel(profile: viewModel.profile)
        let viewController = EditContactProfileViewController(with: editContectProfileViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private 
    
    private func configureView() {
        view.backgroundColor = .systemGray6
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        view.addSubview(profileView)
        view.addSubview(contactInfoTableView)
    }
    
    private func configureLayout() {
        profileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.centerY)
        }
        
        contactInfoTableView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }
    }
    
    private func contactValue(by index: Int) -> (String, String) {
        switch index {
        case Field.email.rawValue:
            return (Field.email.description, viewModel.profile.email)
        case Field.pfone.rawValue:
            return (Field.pfone.description, viewModel.profile.phoneNumber)
        default:
            return ("", "")
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.identifier)
        cell.textLabel?.text = contactValue(by: indexPath.row).1
        cell.detailTextLabel?.text = contactValue(by: indexPath.row).0
        
        return cell
    }
}
