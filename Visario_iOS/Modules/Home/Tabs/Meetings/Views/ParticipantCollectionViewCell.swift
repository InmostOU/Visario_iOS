//
//  ParticipantCollectionViewCell.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 17.08.2021.
//

import UIKit
import AmazonChimeSDK

protocol DoubleTapCellDelegate: AnyObject {
    func doubleTapped()
}

final class ParticipantCollectionViewCell: UICollectionViewCell {
    
    private let profileImageWidth: CGFloat = 100
    private var attendeeId = ""
    
    weak var delegate: DoubleTapCellDelegate?
    var isLocalCell = false
    
    // MARK: - UI
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageWidth / 2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "profile-icon")
        return profileImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Elon Musk"
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        return nameLabel
    }()
    
    private lazy var mutedMicImageView: UIImageView = {
        let mutedMicImageView = UIImageView()
        mutedMicImageView.contentMode = .scaleAspectFill
        mutedMicImageView.tintColor = .white
        mutedMicImageView.image = UIImage(systemName: "mic.slash")
        mutedMicImageView.isHidden = true
        return mutedMicImageView
    }()
    
    lazy var audioLevelView: UIView = {
        let audioLevelView = UIView()
        audioLevelView.backgroundColor = .gray
        audioLevelView.clipsToBounds = true
        audioLevelView.layer.masksToBounds = true
        audioLevelView.layer.cornerRadius = profileImageWidth / 2
        return audioLevelView
    }()
    
    lazy var videoRenderView: DefaultVideoRenderView = {
        let videoRenderView = DefaultVideoRenderView()
        videoRenderView.contentMode = .scaleAspectFill
        videoRenderView.clipsToBounds = true
        videoRenderView.layer.masksToBounds = true
        videoRenderView.isHidden = true
        return videoRenderView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //profileImageView.image = nil
        nameLabel.text = nil
    }
    
    func animate(strength: CGFloat) {
        
        let scale = CGFloat.maximum(strength + 0.5, 1)
        UIView.animate(withDuration: TimeInterval(0.3)) {
            self.audioLevelView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func toggleMutedMic() {
        mutedMicImageView.isHidden.toggle()
    }
    
    func toggleHiddenVideoView() {
        videoRenderView.isHidden.toggle()
    }
    
    func configure(with model: UserInfoResponseModel) {
        if let id = model.attendeeId {
            attendeeId = id
        }
        nameLabel.text = "\(model.firstName) \(model.lastName)"
        profileImageView.sd_setImage(with: URL(string: model.image), placeholderImage: UIImage(named: "profile-icon"))
    }
    
    @objc
    private func doubleTapped() {
        if isLocalCell {
            delegate?.doubleTapped()
        }
    }
    
    private func configureView() {
        backgroundColor = .darkGray
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        gesture.numberOfTapsRequired = 2
        
        addGestureRecognizer(gesture)
        
        contentView.addSubview(audioLevelView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(videoRenderView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(mutedMicImageView)
    }
    
    private func configureLayout() {
        audioLevelView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(profileImageWidth)
        }
        
        profileImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(profileImageWidth)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(13)
        }
        
        videoRenderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mutedMicImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(13)
            $0.top.equalToSuperview().offset(13)
            $0.width.height.equalTo(20)
        }
    }
}
