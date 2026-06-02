//
//  JC_ChatRoomMessageCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ChatRoomMessageCell: UITableViewCell {

    static let reuseIdentifier = "JC_ChatRoomMessageCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: JC_ChatRoomMessage) {
        messageLabel.text = message.text
        avatarImageView.image = message.avatar
        applyLayout(isOutgoing: message.isOutgoing)
    }

    private func applyLayout(isOutgoing: Bool) {
        avatarImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
            if isOutgoing {
                make.trailing.equalToSuperview().offset(-24)
            } else {
                make.leading.equalToSuperview().offset(24)
            }
        }

        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.width.greaterThanOrEqualTo(120)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.62)
            make.bottom.equalToSuperview().offset(-8)
            if isOutgoing {
                make.trailing.equalTo(avatarImageView.snp.leading).offset(-12)
            } else {
                make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            }
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#8DB38B")
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

}
