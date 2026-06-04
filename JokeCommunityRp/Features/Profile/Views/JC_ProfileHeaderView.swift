//
//  JC_ProfileHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ProfileHeaderView: UIView {

    static let headerHeight: CGFloat = 460

    var onSettingTapped: (() -> Void)?
    var onEditProfileTapped: (() -> Void)?
    var onCoinsTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Self.headerHeight))
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with user: JC_UserModel) {
        configure(
            name: user.nickname,
            age: user.ageText,
            bio: user.bio,
            friends: user.friendCountText,
            likes: user.likeCountText,
            avatar: user.avatar
        )
        genderImageView.image = UIImage(named: user.gender.iconName)
    }

    func configure(name: String, age: String, bio: String, friends: String, likes: String, avatar: UIImage?) {
        nameLabel.text = name
        ageLabel.text = age
        bioLabel.text = bio
        friendsCountLabel.text = friends
        likesCountLabel.text = likes
        avatarImageView.image = avatar
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(whiteCardView)
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(genderContainer)
        genderContainer.addSubview(genderImageView)
        genderContainer.addSubview(ageLabel)
        addSubview(settingButton)
        addSubview(bioLabel)
        addSubview(friendsCountLabel)
        addSubview(friendsTitleLabel)
        addSubview(likesCountLabel)
        addSubview(likesTitleLabel)
        addSubview(editProfileButton)
        addSubview(coinBgImageView)
        coinBgImageView.addSubview(coinIconImageView)
        coinBgImageView.addSubview(coinTitleLabel)
        coinBgImageView.addSubview(coinArrowImageView)
        
        
        settingButton.addTarget(self, action: #selector(clickSettingButton), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(clickEditProfileButton), for: .touchUpInside)
        coinBgImageView.addTarget(self, action: #selector(clickCoinsButton), for: .touchUpInside)


        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(65)
            make.leading.equalToSuperview().offset(28)
            make.width.height.equalTo(80)
        }
        
        settingButton.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.trailing.equalToSuperview().offset(-40)
            make.size.equalTo(33)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(11)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(settingButton.snp.leading).offset(-12)
            make.height.equalTo(31)
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

        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(28)
            make.size.equalTo(22)
        }

        whiteCardView.snp.makeConstraints { make in
            make.size.equalTo(175)
            make.top.equalTo(safeAreaLayoutGuide).offset(205)
            make.leading.trailing.bottom.equalToSuperview()
        }

        friendsCountLabel.snp.makeConstraints { make in
            make.top.equalTo(whiteCardView.snp.top).offset(25)
            make.centerX.equalTo(friendsTitleLabel)
            make.height.equalTo(22)
        }

        friendsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsCountLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(22)
        }

        likesCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(friendsCountLabel)
            make.centerX.equalTo(likesTitleLabel)
            make.height.equalTo(22)
        }

        likesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(likesCountLabel.snp.bottom).offset(4)
            make.leading.equalTo(friendsTitleLabel.snp.trailing).offset(65)
            make.height.equalTo(22)
        }

        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(whiteCardView.snp.top).offset(35)
            make.trailing.equalToSuperview().offset(-30)
            make.width.equalTo(106)
            make.height.equalTo(33)
        }

        coinBgImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(64)
        }

        coinIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(21)
            make.centerY.equalToSuperview()
            make.size.equalTo(33)
        }

        coinTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(coinIconImageView.snp.trailing).offset(15)
            make.centerY.equalToSuperview()
        }

        coinArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 9, height: 16))
        }
    }
    
    @objc private func clickSettingButton() {
        onSettingTapped?()
    }

    @objc private func clickEditProfileButton() {
        onEditProfileTapped?()
    }

    @objc private func clickCoinsButton() {
        onCoinsTapped?()
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
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
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

    private let genderImageView = makeImageView(named: "profile_female")

    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let settingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_setting"), for: .normal)
        return button
    }()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let friendsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let friendsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "friend"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 20)
        label.textColor = .black
        return label
    }()

    private let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let likesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "like"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 20)
        label.textColor = .black
        return label
    }()

    private let editProfileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "profile_editBg"), for: .normal)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica-BoldOblique", size: 14) ?? UIFont.italicSystemFont(ofSize: 14)
        return button
    }()

    private let coinBgImageView: UIButton = {
        let v = UIButton(type: .custom)
        v.setBackgroundImage(UIImage(named: "profile_coinBg"), for: .normal)
        return v
    }()

    private let coinIconImageView = makeImageView(named: "profile_coins")

    private let coinTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Get coins"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 22) //?? UIFont.italicSystemFont(ofSize: 18)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let coinArrowImageView = makeImageView(named: "profile_right")

}
