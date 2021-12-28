//
//  StartMeetingViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 14.09.2021.
//

import UIKit

final class StartMeetingViewController: UIViewController {
    
    private lazy var createMeetingImageView: UIImageView = {
        let createMeetingImageView = UIImageView()
        createMeetingImageView.contentMode = .scaleAspectFit
        createMeetingImageView.image = UIImage(systemName: "plus.circle")
        return createMeetingImageView
    }()
    
    private lazy var createMeetingLabel: UILabel = {
        let createMeetingLabel = UILabel()
        createMeetingLabel.text = "Create new meeting"
        return createMeetingLabel
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(viewTap))
        return tapGesture
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(createMeetingImageView)
        view.addSubview(createMeetingLabel)
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureLayout()
    }
    
    @objc
    private func viewTap() {
        let vc = ChannelSelectionViewController()
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
    
    private func configureView() {
        view.addSubview(containerView)
    }
    
    private func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        createMeetingImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().inset(100)
        }
        
        createMeetingLabel.snp.makeConstraints {
            $0.top.equalTo(createMeetingImageView.snp.bottom).offset(10)
            $0.centerX.equalTo(createMeetingImageView)
        }
    }
}
