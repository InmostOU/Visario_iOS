//
//  ChannelMemberTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 01.09.2021.
//

import UIKit
import SDWebImage

final class ChannelMemberTableViewCell: ContactTableViewCell {
    
    func fill(with member: ChannelMember) {
        iconImageView.sd_setImage(with: URL(string: member.image), placeholderImage: UIImage(systemName: "person.crop.circle"))
        titleLabel.text = member.username
        
        if member.online {
            subtitleLabel.text = "online"
            subtitleLabel.textColor = .systemGreen
        } else {
            let timeInterval = TimeInterval(member.lastSeen ?? 0)
            let date = Date(timeIntervalSince1970: timeInterval / 1000)
            let lastSeenDate = date.format(dateFormat: .MMMdHHmm)
            subtitleLabel.text = member.lastSeen != nil ? "Last seen: \(lastSeenDate)" : " - - - "
            subtitleLabel.textColor = .gray
        }
    }
}
