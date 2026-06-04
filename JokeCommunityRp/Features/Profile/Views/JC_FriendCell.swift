//
//  JC_FriendCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

class JC_FriendCell: UITableViewCell {

    static let reuseIdentifier = "JC_FriendCell"

    var onChatTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onChatTapped = nil
    }

    func configure(with item: JC_FriendItem) {
        nameLabel.text = item.name
        avatarImageView.image = item.avatar
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(chatButton)

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        chatButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(14)
            make.trailing.lessThanOrEqualTo(chatButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }

        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
    }

    @objc private func chatTapped() {
        onChatTapped?()
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 20)
            ?? UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_chat"), for: .normal)
        return button
    }()

}
