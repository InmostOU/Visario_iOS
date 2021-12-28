//
//  ContactsConverter.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 20.09.2021.
//

import Foundation

final class ContactsConverter {
    
    // ChannelMember -> ContactModel
    func contactModel(from member: ChannelMember) -> ContactModel {
        ContactModel(id: member.id,
                     userArn: member.userArn,
                     firstName: member.firstName,
                     lastName: member.lastName,
                     username: member.username,
                     email: member.email,
                     phoneNumber: member.phoneNumber,
                     image: member.image,
                     about: member.about,
                     online: member.online,
                     favorite: false,
                     muted: false,
                     inMyContacts: member.inMyContacts)
    }
}
