//
//  EditContactProfileViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 15.08.2021.
//

import UIKit
import SnapKit

final class EditContactProfileViewController: UIViewController, BaseView {
    
    // MARK: - Properties
    
    private let profileImageWidth: CGFloat = 100
    private let viewModel: EditContactProfileViewModel
    
    
    // MARK: - UI
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "elon-musk")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageWidth / 2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        return profileImageView
    }()

    private lazy var settingsTableView: UITableView = {
        let settingsTableView = UITableView(frame: .zero, style: .grouped)
        settingsTableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        settingsTableView.dataSource = self
        settingsTableView.rowHeight = 44
        settingsTableView.contentInset.bottom = 250
        return settingsTableView
    }()
    
    private lazy var deleteContactButton: UIButton = {
        let deleteContactButton = UIButton(type: .system)
        deleteContactButton.setTitle("Delete Contact", for: .normal)
        deleteContactButton.setTitleColor(.red, for: .normal)
        deleteContactButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return deleteContactButton
    }()
    
    init(with viewModel: EditContactProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.view = self
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
    
    // MARK: - Actions
    
    @objc
    private func doneButtonTapped() {
        print("done tapped")
        
        viewModel.editContact { [weak self] in
            guard let self = self else { return }
            
            self.view.showSuccessHUD()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func deleteButtonTapped() {
        print("delete tapped")
        
        viewModel.deleteContact { [weak self] in
            guard let self = self else { return }
            
            self.view.showSuccessHUD()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Private
    
    private func configureView() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        view.addSubview(profileImageView)
        view.addSubview(settingsTableView)
        view.addSubview(deleteContactButton)
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(profileImageWidth)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(50)
        }
        
        settingsTableView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        deleteContactButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-100)
        }
    }
}

// MARK: - UITableViewDataSource

extension EditContactProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsDataSource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
        
        let model = viewModel.settingsDataSource[indexPath.section].items[indexPath.row]
        
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configure(with: model, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.settingsDataSource[section].footerTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settingsDataSource.count
    }
}

// MARK: - TextFieldCellDelegate

extension EditContactProfileViewController: TextFieldCellDelegate {
    
    func setText(text: String, by indexPath: IndexPath) {
        switch indexPath.section {
        
        case SectionType.name.rawValue:
            switch indexPath.row {
            case NamesRowType.firstName.rawValue:
                viewModel.profile.firstName = text
            case NamesRowType.lastName.rawValue:
                viewModel.profile.lastName = text
            default:
                return
            }
            
        default:
            return
        }
    }
}


