//
//  ProfileSettingTableViewCell.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import UIKit
import SnapKit

protocol TextFieldCellDelegate: AnyObject {
    func setText(text: String, by indexPath: IndexPath)
}

final class TextFieldTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    private let privacyPicker = UIPickerView()
    private let toolbar = UIToolbar()
    private var model: TextFieldModel?
    private var index = IndexPath(row: 0, section: 0)
    
    weak var delegate: TextFieldCellDelegate?
    
    // MARK: - UI
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .allEditingEvents)
        textField.innerPaddings(left: 16, right: 16)
        return textField
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textField)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.sizeToFit()
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        privacyPicker.delegate = self
        privacyPicker.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.text = nil
    }
    
    // MARK: - Actions
    
    @objc
    private func textFieldChanged() {
        delegate?.setText(text: textField.text ?? "", by: index)
    }
    
    @objc
    private func doneTapped() {
        guard let model = model else { return }
        
        if model.isDateField {
            getDateFromPicker()
        }
        
        textField.endEditing(true)
    }
    
    // MARK: - Public
    
    public func configure(with model: TextFieldModel, indexPath: IndexPath) {
        self.index = indexPath
        textField.text = model.text
        textField.placeholder = model.placeholder
        
        self.model = model
        
        if model.isDateField {
            textField.textAlignment = .center
            textField.inputView = datePicker
            textField.inputAccessoryView = toolbar
            setTextFieldRightView()
            textField.tintColor = UIColor.clear
        }
        
        if model.isPrivacyField {
            textField.textAlignment = .center
            textField.inputView = privacyPicker
            textField.inputAccessoryView = toolbar
            setTextFieldRightView()
            textField.tintColor = UIColor.clear
        }
    }
    
    // MARK: - Private
    
    private func setTextFieldRightView() {
        let imageView = UIImageView(frame: CGRect(x: -4.0, y: 5.0, width: 24.0, height: 24.0))
        let image = UIImage(systemName: "chevron.down")
        imageView.image = image
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit

        let view = UIView(frame: CGRect(x: 12, y: 0, width: 32, height: 32))
        view.addSubview(imageView)
        
        textField.rightView = view
        textField.rightViewMode = .always
    }
    
    private func getDateFromPicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        textField.text = formatter.string(from: datePicker.date)
    }
    
    private func configureLayout() {
        textField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension TextFieldTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Constants.privacySettings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.privacySettings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = Constants.privacySettings[row]
    }
}
