//
//  TableBackgroundView.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 11.08.2021.
//

import UIKit

class TableBackgroundView: UIView {

    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .gray
        label.layer.opacity = 0
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        addSubview(titleLabel)
    }

    private func configureConstraints() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalTo(layoutMarginsGuide)
        }
    }

    func fill(with title: String) {
        titleLabel.text = title
        
        UIView.animate(withDuration: 1, delay: 0.5) {
            self.titleLabel.layer.opacity = 1
        }
    }

}

