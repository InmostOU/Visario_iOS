//
//  EditProfileViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 10.08.2021.
//

import UIKit
import SnapKit

struct TableViewData {
    let footerTitle: String
    let items: [TextFieldModel]
}

enum SectionType: Int {
    case name = 0
    case about
    case username
    case birthday
    case privacy
}

enum NamesRowType: Int {
    case firstName = 0
    case lastName
}

enum AboutRowType: Int {
    case about = 0
}

enum UsernameRowType: Int {
    case username = 0
}

enum BirthdayRowType: Int {
    case birthday = 0
}

enum PrivacyRowType: Int {
    case whoCanSeeNumber = 0
    case whoCanSeeEmail
}

final class EditProfileViewController: UIViewController, BaseView {
    
    // MARK: - Properties
    
    private let profileImageWidth: CGFloat = 100
    private let viewModel: EditProfileViewModel
    
    
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
    
    private lazy var setNewPhotoButton: UIButton = {
        let setNewPhotoButton = UIButton(type: .system)
        setNewPhotoButton.setTitle("Set New Photo", for: .normal)
        setNewPhotoButton.setTitleColor(.systemBlue, for: .normal)
        setNewPhotoButton.titleLabel?.font = .systemFont(ofSize: 16)
        setNewPhotoButton.addTarget(self, action: #selector(setNewPhotoButtonTapped), for: .touchUpInside)
        return setNewPhotoButton
    }()

    private lazy var settingsTableView: UITableView = {
        let settingsTableView = UITableView(frame: .zero, style: .grouped)
        settingsTableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        settingsTableView.dataSource = self
        settingsTableView.rowHeight = 44
        settingsTableView.contentInset.bottom = 250
        return settingsTableView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Init
    
    init(with viewModel: EditProfileViewModel) {
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
    private func setNewPhotoButtonTapped() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc
    private func doneButtonTapped() {
        print("done tapped")
        print(viewModel.updatedProfile)
        
        viewModel.updateUserProfile() { [weak self] in
            guard let self = self else { return }
            
            self.view.showSuccessHUD()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: - Private
    
    private func configureView() {
        view.backgroundColor = .systemGray6
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        profileImageView.sd_imageTransition = .fade
        profileImageView.sd_setImage(with: URL(string: viewModel.profile.image), placeholderImage: UIImage(named: "elon-musk"))
        
        containerView.addSubviews(profileImageView, setNewPhotoButton)
        view.addSubview(containerView)
       
        view.addSubview(settingsTableView)
    }
    
    private func configureLayout() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(250)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(profileImageWidth)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(50)
        }
        
        setNewPhotoButton.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        settingsTableView.snp.makeConstraints {
            $0.top.equalTo(setNewPhotoButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UIImagePicker Extensions

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        profileImageView.image = image
        
        viewModel.uploadUserPhoto(image: image)
        
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension EditProfileViewController: UITableViewDataSource {
    
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

extension EditProfileViewController: TextFieldCellDelegate {
    
    func setText(text: String, by indexPath: IndexPath) {
        
        switch indexPath.section {
        case SectionType.name.rawValue:
            switch indexPath.row {
            case NamesRowType.firstName.rawValue:
                viewModel.updatedProfile.firstName = text
            case NamesRowType.lastName.rawValue:
                viewModel.updatedProfile.lastName = text
            default:
                return
            }
        case SectionType.about.rawValue:
            switch indexPath.row {
            case AboutRowType.about.rawValue:
                viewModel.updatedProfile.about = text
            default:
                return
            }
        case SectionType.username.rawValue:
            switch indexPath.row {
            case UsernameRowType.username.rawValue:
                viewModel.updatedProfile.username = text
            default:
                return
            }
        case SectionType.birthday.rawValue:
            switch indexPath.row {
            case BirthdayRowType.birthday.rawValue:
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy"
                let timeIntervalDate = formatter.date(from: text)?.timeIntervalSince1970
                viewModel.updatedProfile.birthday = Int(timeIntervalDate ?? 0)
            default:
                return
            }
        case SectionType.privacy.rawValue:
            switch indexPath.row {
            case PrivacyRowType.whoCanSeeNumber.rawValue:
                viewModel.updatedProfile.showPhoneNumberTo = Privacy(rawValue: text)
            case PrivacyRowType.whoCanSeeEmail.rawValue:
                viewModel.updatedProfile.showEmailTo = Privacy(rawValue: text)
            default:
                return
            }
        default:
            return
        }
    }
}
