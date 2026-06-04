//
//  JC_HomeVideoCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit
import AVFoundation

class JC_HomeVideoCell: UICollectionViewCell {

    static let reuseIdentifier = "JC_HomeVideoCell"

    var onLikeTapped: ((String) -> Void)?
    var onDislikeTapped: ((String) -> Void)?
    var onReportTapped: ((String) -> Void)?

    private var postId: String = ""
    private var authorUserId: String = ""
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var endObserver: NSObjectProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stop()
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onLikeTapped = nil
        onDislikeTapped = nil
        onReportTapped = nil
        postId = ""
        authorUserId = ""
        collectBadgeView.isHidden = false
        applyLikeState(isLiked: false, likeCount: "0")
        applyDislikeState(isDisliked: false, dislikeCount: "0")
    }

    func configure(with item: JC_HomeVideoItem) {
        stop()
        postId = item.postId
        authorUserId = item.authorUserId
        avatarImageView.image = item.avatar
        jokeLabel.text = item.jokeText
        applyLikeState(isLiked: item.isLiked, likeCount: item.likeCount)
        applyDislikeState(isDisliked: item.isDisliked, dislikeCount: item.dislikeCount)
        updateCollectBadgeVisibility()

        let playerItem = AVPlayerItem(url: item.videoURL)
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .pause

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = contentView.bounds
        contentView.layer.insertSublayer(layer, at: 0)

        self.player = player
        playerLayer = layer

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        pause()
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
    }

    private func setupUI() {
        contentView.backgroundColor = .black

        contentView.addSubview(rightActionView)
        rightActionView.addSubview(avatarImageView)
        rightActionView.addSubview(collectBadgeView)
        rightActionView.addSubview(likeButton)
        rightActionView.addSubview(likeCountLabel)
        rightActionView.addSubview(dislikeButton)
        rightActionView.addSubview(dislikeCountLabel)
        rightActionView.addSubview(reportButton)

        contentView.addSubview(jokeContainerView)
        jokeContainerView.addSubview(jokeLabel)

        rightActionView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(jokeContainerView.snp.top).offset(-24)
            make.width.equalTo(65)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        collectBadgeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(avatarImageView).offset(12.5)
            make.width.height.equalTo(25)
        }

        likeButton.snp.makeConstraints { make in
            make.top.equalTo(collectBadgeView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }

        likeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        dislikeButton.snp.makeConstraints { make in
            make.top.equalTo(likeCountLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }

        dislikeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(dislikeButton.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        reportButton.snp.makeConstraints { make in
            make.top.equalTo(dislikeCountLabel.snp.bottom).offset(16)
            make.centerX.bottom.equalToSuperview()
            make.width.height.equalTo(36)
        }

        jokeContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(rightActionView.snp.leading).offset(-25)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).offset(-70)
        }

        jokeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }

        configureLikeButton(likeButton)
        configureDislikeButton(dislikeButton)
        collectBadgeView.addTarget(self, action: #selector(likeCollect), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(dislikeTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
    }

    private func configureLikeButton(_ button: UIButton) {
        let pointSize = likeSymbolPointSize()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        let normalHeart = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)
        let selectedHeart = UIImage(named: "home_like")
        button.setImage(normalHeart, for: .normal)
        button.setImage(selectedHeart, for: .selected)
        button.tintColor = .white
    }

    private func likeSymbolPointSize() -> CGFloat {
        let likeSize = imageDisplaySize(named: "home_like")
        if likeSize.height > 0 {
            return likeSize.height
        }
        return 36
    }

    private func updateLikeButtonAppearance() {
        likeButton.tintColor = likeButton.isSelected ? UIColor(hex: "#FFCC00") : .white
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

    private func configureDislikeButton(_ button: UIButton) {
        let image = UIImage(named: "home_dislike")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .selected)
        updateDislikeButtonAppearance()
    }

    private func updateDislikeButtonAppearance() {
        dislikeButton.tintColor = dislikeButton.isSelected ? .black : .white
    }
    
    @objc private func likeCollect() {
        guard !authorUserId.isEmpty else { return }
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        guard authorUserId != currentUserId else { return }

        _ = JC_CurrentUser.shared.toggleFollow(userId: authorUserId)
        updateCollectBadgeVisibility()
    }

    private func updateCollectBadgeVisibility() {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        let isSelf = authorUserId == currentUserId
        let isFollowing = JC_CurrentUser.shared.isFollowing(userId: authorUserId)
        collectBadgeView.isHidden = isSelf || isFollowing
    }
    
    @objc private func likeTapped() {
        guard !postId.isEmpty else { return }
        onLikeTapped?(postId)
    }
    
    @objc private func dislikeTapped() {
        guard !postId.isEmpty else { return }
        onDislikeTapped?(postId)
    }
    
    @objc private func reportTapped() {
        guard !postId.isEmpty else { return }
        onReportTapped?(postId)
    }

    private let rightActionView = UIView()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let collectBadgeView: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_collect"), for: .normal)
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let dislikeButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()

    private let dislikeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let reportButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_report"), for: .normal)
        return button
    }()

    private let jokeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let jokeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

}
