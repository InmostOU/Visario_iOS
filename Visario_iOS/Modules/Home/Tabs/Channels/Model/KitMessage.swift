//
//  KitMessage.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 15.08.2021.
//

import MessageKit

enum FileType: String {
    case image
    case document
    case noType
}

struct AudioFileItem: AudioItem {
    var url: URL
    var size: CGSize
    var duration: Float
}

struct FileLinkItem: LinkItem {
    var text: String?
    var attributedText: NSAttributedString?
    var url: URL
    var title: String?
    var teaser: String
    var thumbnailImage: UIImage
}

struct KitMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    // extended
    var content: String
    var createdTimestamp: Int
    var lastEditedTimestamp: Int
    var metadata: String
    var redacted: Bool
    var senderArn: String
    var senderName: String
    var type: TypeOfMessage
    var channelArn: String
    var fromCurrentUser: Bool
    var delivered: Bool
    var image: UIImage?
    var file: Data?
    var imageURL: String?
    var fileURL: String?
    var fileName: String?
    var audioDuration: Float?
    
    var kind: MessageKind {
        guard let placeholder = UIImage(named: "placeholder") else { return .text(content) }
        let photoFrameSize = CGSize(width: 300, height: 200)
        
        if let image = image {
            return .photo(Media(url: nil, image: image, placeholderImage: placeholder, size: photoFrameSize))
        } else if let url = imageURL {
            return .photo(Media(url: URL(string: url), image: nil, placeholderImage: placeholder, size: photoFrameSize))
        } else if var url = fileURL, url.isTextFileType() {
            var fileName = ""
            
            if file != nil {
                if let filename = url.components(separatedBy: "/").last {
                    fileName = filename
                }
            } else {
                if let metadata = parseMetadata(from: metadata) {
                    fileName = metadata.fileName + "." + metadata.fileType
                    url = metadata.url
                }
            }
            
            let fileSize = URL(string: content)?.fileSize ?? 0
            let image = UIImage(systemName: "doc")!.withRenderingMode(.alwaysOriginal)
            
            let linkItem = FileLinkItem(text: "Attachment", url: URL(string: url)!, title: fileName, teaser: String(fileSize) + " Bytes", thumbnailImage: image)
            return .linkPreview(linkItem)
        } else if let url = fileURL, url.isAudioFileType() {
            guard let url = URL(string: url) else { return .text("Error") }
            let size = CGSize(width: 200, height: 50)
            let audioItem = AudioFileItem(url: url, size: size, duration: audioDuration ?? 0)
            return .audio(audioItem)
        } else if content.contains(Constants.meetingPath) {
            let frameSize = CGSize(width: 220, height: 50)
            return .photo(Media(url: URL(string: content), image: nil, placeholderImage: placeholder, size: frameSize))
        } else {
            return .text(content)
        }
    }
    
    static var placeholder: Self {
        return KitMessage(sender: Sender(senderId: "", displayName: ""),
                          messageId: "",
                          sentDate: Date(),
                          content: "",
                          createdTimestamp: 0,
                          lastEditedTimestamp: 0,
                          metadata: "",
                          redacted: false,
                          senderArn: "",
                          senderName: "",
                          type: .standard,
                          channelArn: "",
                          fromCurrentUser: false,
                          delivered: false,
                          image: nil,
                          imageURL: "")
    }
    
    private func parseMetadata(from metadata: String) -> Metadata? {
        do {
            let data = metadata.data(using: .utf8) ?? Data()
            let metadata = try JSONDecoder().decode(Metadata.self, from: data)
            return metadata
        } catch {
            //print(error)
            return nil
        }
    }
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

// MARK: - Equatable

extension KitMessage: Equatable {
    
    static func == (lhs: KitMessage, rhs: KitMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
}
