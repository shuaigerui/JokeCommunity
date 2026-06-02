//
//  JC_PostCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PostCell: UITableViewCell {

    static let reuseIdentifier = "JC_PostCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with post: JC_PostItem) {
        nameLabel.text = post.userName
        ageLabel.text = post.age
        avatarImageView.image = post.avatar
        contentLabel.text = post.content
        likeCountLabel.text = post.likeCount
        addFriendButton.isHidden = !post.showAddFriend

        leftImageView.image = post.images.first ?? nil
        let hasSecondImage = post.images.count > 1
        rightImageView.isHidden = !hasSecondImage
        rightImageView.image = hasSecondImage ? post.images[1] : nil
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(genderContainer)
        genderContainer.addSubview(genderImageView)
        genderContainer.addSubview(ageLabel)
        contentView.addSubview(addFriendButton)
        contentView.addSubview(menuButton)
        contentView.addSubview(contentLabel)
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(leftImageView)
        imageContainerView.addSubview(rightImageView)
        contentView.addSubview(actionView)
        actionView.addSubview(likeButton)
        actionView.addSubview(likeCountLabel)
        actionView.addSubview(dislikeButton)
        actionView.addSubview(reportButton)
        contentView.addSubview(lineView)

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(30)
            make.size.equalTo(50)
        }

        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
            make.centerY.equalTo(avatarImageView)
            make.size.equalTo(32)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(menuButton.snp.leading).offset(-12)
        }

        genderContainer.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
            make.height.equalTo(22)
        }

        genderImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(13)
        }

        ageLabel.snp.makeConstraints { make in
            make.leading.equalTo(genderImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        addFriendButton.snp.makeConstraints { make in
            make.leading.equalTo(genderContainer.snp.trailing).offset(10)
            make.centerY.equalTo(genderContainer)
            make.height.equalTo(26)
            make.width.equalTo(96)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        imageContainerView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(200)
        }

        leftImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(rightImageView)
        }

        rightImageView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(leftImageView.snp.trailing).offset(12)
            make.width.equalTo(leftImageView)
        }

        actionView.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(22)
        }

        likeButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        likeCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(likeButton.snp.trailing).offset(6)
            make.centerY.equalTo(likeButton)
        }

        dislikeButton.snp.makeConstraints { make in
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(25)
            make.centerY.equalToSuperview()
            make.size.equalTo(21)
        }

        reportButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        lineView.snp.makeConstraints { make in
            make.top.equalTo(actionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let genderContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        return view
    }()

    private let genderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile_female"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let addFriendButton: UIButton = {
        let button = makeAssetButton(imageName: "post_add")
        return button
    }()

    private let menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(hex: "#333333")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        button.setImage(
            UIImage(systemName: "line.3.horizontal", withConfiguration: config),
            for: .normal
        )
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        return button
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        label.textColor = UIColor(hex: "#333333")
        label.numberOfLines = 0
        return label
    }()

    private let imageContainerView = UIView()

    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(hex: "#F2F2F2")
        return imageView
    }()

    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(hex: "#F2F2F2")
        return imageView
    }()

    private let actionView = UIView()

    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_like"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let dislikeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_dislike"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let reportButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "post_report"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#333333")
        return view
    }()

}
