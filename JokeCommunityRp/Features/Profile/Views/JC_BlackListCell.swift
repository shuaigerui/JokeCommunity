//
//  JC_BlackListCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_BlackListCell: UITableViewCell {

    static let reuseIdentifier = "JC_BlackListCell"

    var onDeleteTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: JC_BlackListItem) {
        nameLabel.text = item.userName
        avatarImageView.image = item.avatar
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(deleteButton)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(72)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(14)
            make.trailing.lessThanOrEqualTo(deleteButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }

        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .jc_yellow
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "#333333").cgColor
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

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 20)
            ?? UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "black_del"), for: .normal)
        return button
    }()

}
