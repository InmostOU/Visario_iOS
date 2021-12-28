//
//  AddMemberToChannelTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 25.08.2021.
//

import UIKit

protocol AddMemberCellDelegate: AnyObject {
    func add(member: ContactModel)
}

final class AddMemberToChannelTableViewCell: ContactTableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: AddMemberCellDelegate?
}
