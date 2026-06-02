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

    func configure(with item: JC_HomeVideoItem) {
        stop()
        jokeLabel.text = item.jokeText
        likeCountLabel.text = item.likeCount
        commentCountLabel.text = item.commentCount

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
        rightActionView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(collectBadgeView)
        rightActionView.addSubview(likeButton)
        rightActionView.addSubview(likeCountLabel)
        rightActionView.addSubview(dislikeButton)
        rightActionView.addSubview(commentCountLabel)
        rightActionView.addSubview(reportButton)

        contentView.addSubview(jokeContainerView)
        jokeContainerView.addSubview(jokeLabel)

        rightActionView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(jokeContainerView.snp.top).offset(-24)
            make.width.equalTo(60)
        }

        avatarContainer.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectBadgeView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().offset(4)
            make.width.height.equalTo(22)
        }

        likeButton.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer.snp.bottom).offset(20)
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

        commentCountLabel.snp.makeConstraints { make in
            make.top.equalTo(dislikeButton.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        reportButton.snp.makeConstraints { make in
            make.top.equalTo(commentCountLabel.snp.bottom).offset(16)
            make.centerX.bottom.equalToSuperview()
            make.width.height.equalTo(36)
        }

        jokeContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(rightActionView.snp.leading).offset(-12)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).offset(-100)
        }

        jokeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        }
    }

    private let rightActionView = UIView()

    private let avatarContainer = UIView()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(hex: "#CCCCCC")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 28
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    private let collectBadgeView = makeImageView(named: "home_collect")

    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_like")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.isUserInteractionEnabled = false
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
        button.setImage(UIImage(named: "home_dislike")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let reportButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_report")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let jokeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let jokeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

}
