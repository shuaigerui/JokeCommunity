//
//  JC_PersonHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PersonHeaderView: UIView {

    static let headerHeight: CGFloat = 175

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Self.headerHeight))
        setupUI()
        configure(
            name: "Angela",
            age: "20",
            bio: "This is my first time sharing a joke, I .......",
            avatar: nil,
            gender: .female,
            showAddFriend: true
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        name: String,
        age: String,
        bio: String,
        avatar: UIImage?,
        gender: JC_UserGender,
        showAddFriend: Bool
    ) {
        nameLabel.text = name
        ageLabel.text = age
        bioLabel.text = bio
        avatarImageView.image = avatar
        genderImageView.image = UIImage(named: gender.iconName)
        addFriendButton.isHidden = !showAddFriend
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(whiteCardView)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(genderContainer)
        genderContainer.addSubview(genderImageView)
        genderContainer.addSubview(ageLabel)
        addSubview(addFriendButton)
        addSubview(bioLabel)

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(28)
            make.size.equalTo(68)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(8)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-28)
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

        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(28)
        }

        whiteCardView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }

    private let whiteCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 34
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
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

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

}
