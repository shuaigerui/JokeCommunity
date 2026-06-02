//
//  JC_ChatMessageCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ChatMessageCell: UITableViewCell {

    static let reuseIdentifier = "JC_ChatMessageCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: JC_ChatMessage) {
        titleLabel.text = message.userName
        previewLabel.text = message.preview
        avatarImageView.image = message.avatar
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(previewLabel)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(72)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(2)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-16)
        }

        previewLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(titleLabel)
        }
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#8FB38D")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

}
