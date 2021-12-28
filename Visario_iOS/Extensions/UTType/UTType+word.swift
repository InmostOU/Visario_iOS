//
//  UTType+word.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 20.10.2021.
//

import UniformTypeIdentifiers

enum SupportedImageFileType: String, CaseIterable {
    case jpeg
    case jpg
    case png
}

enum SupportedAudioFileType: String, CaseIterable {
    case m4a
}

enum SupportedTextFileType: String, CaseIterable {
    case doc
    case docx
    case xls
    case xlsx
    case pdf
    case txt
}

extension UTType {
    
    // Word documents are not an existing property on UTType
    static var doc: UTType {
        // Look up the type from the file extension
        UTType.types(tag: SupportedTextFileType.doc.rawValue, tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var docx: UTType {
        UTType.types(tag: SupportedTextFileType.docx.rawValue, tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var xls: UTType {
        UTType.types(tag: SupportedTextFileType.xls.rawValue, tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var xlsx: UTType {
        UTType.types(tag: SupportedTextFileType.xlsx.rawValue, tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
}

