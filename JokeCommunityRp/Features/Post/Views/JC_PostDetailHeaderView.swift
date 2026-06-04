//
//  JC_PostDetailHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PostDetailHeaderView: UIView {

    static let headerHeight: CGFloat = 415

    var onAvatarTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onDislikeTapped: (() -> Void)?

    private var postId: String = ""
    private var authorUserId: String = ""

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Self.headerHeight))
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with post: JC_PostItem, relationText: String = "Good Friend") {
        postId = post.postId
        authorUserId = post.authorUserId
        nameLabel.text = post.userName
        ageLabel.text = post.age
        genderImageView.image = UIImage(named: post.gender.iconName)
        avatarImageView.image = post.avatar
        contentLabel.text = post.content
        applyLikeState(isLiked: post.isLiked, likeCount: post.likeCount)
        applyDislikeState(isDisliked: post.isDisliked, dislikeCount: post.dislikeCount)

        leftImageView.image = post.images.first ?? nil
        let hasSecondImage = post.images.count > 1
        rightImageView.isHidden = !hasSecondImage
        rightImageView.image = hasSecondImage ? post.images[1] : nil
        updateRelationButtonState()
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(genderContainer)
        genderContainer.addSubview(genderImageView)
        genderContainer.addSubview(ageLabel)
        addSubview(relationButton)
        addSubview(contentLabel)
        addSubview(imageContainerView)
        imageContainerView.addSubview(leftImageView)
        imageContainerView.addSubview(rightImageView)
        addSubview(actionView)
        actionView.addSubview(likeButton)
        actionView.addSubview(likeCountLabel)
        actionView.addSubview(dislikeButton)
        actionView.addSubview(dislikeCountLabel)
        addSubview(lineView)

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(30)
            make.size.equalTo(68)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-30)
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

        relationButton.snp.makeConstraints { make in
            make.leading.equalTo(genderContainer.snp.trailing).offset(10)
            make.centerY.equalTo(genderContainer)
            make.width.equalTo(96)
            make.height.equalTo(26)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        imageContainerView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(199)
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

        dislikeCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(dislikeButton.snp.trailing).offset(6)
            make.centerY.equalTo(dislikeButton)
        }

        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }

        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        )
        configureLikeButton(likeButton)
        configureDislikeButton(dislikeButton)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(dislikeTapped), for: .touchUpInside)
        relationButton.addTarget(self, action: #selector(relationTapped), for: .touchUpInside)
    }
    
    @objc private func avatarTapped() {
        onAvatarTapped?()
    }

    @objc private func likeTapped() {
        guard !postId.isEmpty else { return }
        onLikeTapped?()
    }

    @objc private func dislikeTapped() {
        guard !postId.isEmpty else { return }
        onDislikeTapped?()
    }
    
    @objc private func relationTapped() {
        guard !authorUserId.isEmpty else { return }
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        guard authorUserId != currentUserId else { return }

        _ = JC_CurrentUser.shared.toggleFollow(userId: authorUserId)
        updateRelationButtonState()
    }

    private func updateRelationButtonState() {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        let isSelf = authorUserId == currentUserId
        relationButton.isHidden = isSelf
        relationButton.isSelected = JC_CurrentUser.shared.isFollowing(userId: authorUserId)
    }

    func applyLikeState(isLiked: Bool, likeCount: String) {
        likeButton.isSelected = isLiked
        updateLikeButtonAppearance()
        likeCountLabel.text = likeCount
    }

    func applyDislikeState(isDisliked: Bool, dislikeCount: String) {
        dislikeButton.isSelected = isDisliked
        updateDislikeButtonAppearance()
        dislikeCountLabel.text = dislikeCount
    }

    private func configureLikeButton(_ button: UIButton) {
        let image = UIImage(named: "profile_like")
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .selected)
        updateLikeButtonAppearance()
    }

    private func updateLikeButtonAppearance() {
        likeButton.tintColor = likeButton.isSelected ? UIColor(hex: "#E5404F") : UIColor(hex: "#333333")
    }

    private func configureDislikeButton(_ button: UIButton) {
        let image = UIImage(named: "profile_dislike")
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .selected)
        updateDislikeButtonAppearance()
    }

    private func updateDislikeButtonAppearance() {
        if dislikeButton.isSelected {
            dislikeButton.tintColor = nil
        } else {
            dislikeButton.tintColor = .white
        }
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 34
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        imageView.isUserInteractionEnabled = true
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

    private let relationButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(named: "post_friended"), for: .selected)
        v.setImage(UIImage(named: "post_friend"), for: .normal)
        return v
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
        return button
    }()

    private let dislikeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CCCCCC")
        return view
    }()

}
