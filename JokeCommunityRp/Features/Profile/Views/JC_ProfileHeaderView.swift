//
//  JC_ProfileHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ProfileHeaderView: UIView {

    static let headerHeight: CGFloat = 425

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Self.headerHeight))
        setupUI()
        configure(
            name: "Angela",
            age: "20",
            bio: "This is my first time sharing a joke, I .......",
            friends: "950",
            likes: "999+",
            avatar: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addSubview(lineImageView)
        addSubview(friendsCountLabel)
        addSubview(friendsTitleLabel)
        addSubview(likesCountLabel)
        addSubview(likesTitleLabel)
        addSubview(editProfileButton)
        addSubview(coinBannerView)
        coinBannerView.addSubview(coinBgImageView)
        coinBannerView.addSubview(coinIconImageView)
        coinBannerView.addSubview(coinTitleLabel)
        coinBannerView.addSubview(coinArrowImageView)

        let settingSize = imageDisplaySize(named: "profile_setting", height: 33)
        let genderSize = imageDisplaySize(named: "性别", height: 13)
        let coinIconSize = imageDisplaySize(named: "profile_coins", height: 42)
        let coinArrowSize = imageDisplaySize(named: "profile_right", height: 16)

        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-25)
            make.size.equalTo(settingSize == .zero ? CGSize(width: 33, height: 33) : settingSize)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(78)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(86)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(8)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualTo(settingButton.snp.leading).offset(-12)
        }

        genderContainer.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
            make.height.equalTo(24)
        }

        genderImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(genderSize == .zero ? CGSize(width: 13, height: 13) : genderSize)
        }

        ageLabel.snp.makeConstraints { make in
            make.leading.equalTo(genderImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(21)
            make.trailing.equalToSuperview().offset(-21)
        }

        whiteCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(210)
            make.leading.trailing.bottom.equalToSuperview()
        }

        lineImageView.snp.makeConstraints { make in
            make.top.equalTo(whiteCardView).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        friendsCountLabel.snp.makeConstraints { make in
            make.top.equalTo(lineImageView.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(28)
        }

        friendsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsCountLabel.snp.bottom).offset(4)
            make.centerX.equalTo(friendsCountLabel)
        }

        likesCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(friendsCountLabel)
            make.leading.equalTo(friendsCountLabel.snp.trailing).offset(36)
        }

        likesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(likesCountLabel.snp.bottom).offset(4)
            make.centerX.equalTo(likesCountLabel)
        }

        editProfileButton.snp.makeConstraints { make in
            make.centerY.equalTo(friendsCountLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-24)
            make.width.equalTo(106)
            make.height.equalTo(33)
        }

        coinBannerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(49)
        }

        coinBgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        coinIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.size.equalTo(coinIconSize == .zero ? CGSize(width: 42, height: 42) : coinIconSize)
        }

        coinTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(coinIconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }

        coinArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.size.equalTo(coinArrowSize == .zero ? CGSize(width: 9, height: 16) : coinArrowSize)
        }
    }

    private static func resizableCoinBgImage() -> UIImage? {
        guard let image = UIImage(named: "profile_coinBg") else { return nil }
        let cap = image.size.height / 2
        return image.resizableImage(
            withCapInsets: UIEdgeInsets(top: 0, left: cap, bottom: 0, right: cap),
            resizingMode: .stretch
        )
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
        imageView.layer.cornerRadius = 43
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
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
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let genderImageView = makeImageView(named: "性别")

    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let settingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_setting")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = UIColor(hex: "#333333")
        label.numberOfLines = 2
        return label
    }()

    private let lineImageView = makeImageView(named: "profile_line")

    private let friendsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let friendsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "friend"
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#999999")
        return label
    }()

    private let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let likesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "like"
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#999999")
        return label
    }()

    private let editProfileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(JC_ProfileHeaderView.resizableCoinBgImage(), for: .normal)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica-BoldOblique", size: 14) ?? UIFont.italicSystemFont(ofSize: 14)
        return button
    }()

    private let coinBannerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private let coinBgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = JC_ProfileHeaderView.resizableCoinBgImage()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let coinIconImageView = makeImageView(named: "profile_coins")

    private let coinTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Get coins"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 18) ?? UIFont.italicSystemFont(ofSize: 18)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let coinArrowImageView = makeImageView(named: "profile_right")

}
