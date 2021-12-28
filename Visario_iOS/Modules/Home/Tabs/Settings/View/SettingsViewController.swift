//
//  SettingsViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.08.2021.
//

import UIKit

struct SettingOption {
    let title: String
    let icon: UIImage?
    let iconBackground: UIColor
    let handler: (() -> Void)?
}

protocol SettingsView: BaseView {
    func configureProfileInfoView(profile: ProfileModel)
    func goTohangePasswordView()
    func showAlert()
}

final class SettingsViewController: UIViewController {
    
    private let viewModel = SettingsViewModel()
    
    // MARK: - UI Elements
    
    private lazy var profileInfoView: ProfileInfoView = {
        let profileInfoView = ProfileInfoView()
        profileInfoView.backgroundColor = .white
        return profileInfoView
    }()
    
    private lazy var settingsTableView: UITableView = {
        let settingsTableView = UITableView(frame: .zero, style: .grouped)
        settingsTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        return settingsTableView
    }()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        viewModel.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureLayout()
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppear()
        
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
    
    // MARK: - Private
    
    private func setupViews() {
        view.backgroundColor = .systemGray6
        view.addSubview(profileInfoView)
        view.addSubview(settingsTableView)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    private func configureLayout() {
        profileInfoView.snp.makeConstraints {
            $0.leading.trailing.top.width.equalToSuperview()
            $0.height.equalTo(240)
        }
        
        settingsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(profileInfoView.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func editTapped() {
        guard let profile = viewModel.profile else { return }
        let editProfileViewModel = EditProfileViewModel(profile: profile)
        let viewController = EditProfileViewController(with: editProfileViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        
        let setting = viewModel.settings[indexPath.row]
        
        cell.configure(with: setting)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.settings[indexPath.row].handler?()
    }
}

// MARK: - SettingsView

extension SettingsViewController: SettingsView {
    
    func configureProfileInfoView(profile: ProfileModel) {
        profileInfoView.setModel(profile: profile)
    }
    
    func goTohangePasswordView() {
        let changePasswordViewController = ChangePasswordViewController()
        navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in self?.viewModel.logout() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.preferredAction = okAction
        
        present(alertController, animated: true)
    }
    
}
