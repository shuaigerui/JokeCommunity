//
//  JC_ProfilePostCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ProfilePostCell: UITableViewCell {

    static let reuseIdentifier = "JC_ProfilePostCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with post: JC_ProfilePost) {
        contentLabel.text = post.content
        likeCountLabel.text = post.likeCount

        leftImageView.image = post.images.first ?? nil
        let hasSecondImage = post.images.count > 1
        rightImageView.isHidden = !hasSecondImage
        rightImageView.image = hasSecondImage ? post.images[1] : nil

        updateImageLayout(hasSecondImage: hasSecondImage)
    }

    private func updateImageLayout(hasSecondImage: Bool) {
        leftImageView.snp.remakeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            if hasSecondImage {
                make.width.equalTo(rightImageView)
            } else {
                make.trailing.equalToSuperview()
            }
        }

        rightImageView.snp.remakeConstraints { make in
            guard hasSecondImage else { return }
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(leftImageView.snp.trailing).offset(imageSpacing)
            make.width.equalTo(leftImageView)
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white

        contentView.addSubview(contentLabel)
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(leftImageView)
        imageContainerView.addSubview(rightImageView)
        contentView.addSubview(actionView)
        actionView.addSubview(likeButton)
        actionView.addSubview(likeCountLabel)
        actionView.addSubview(dislikeButton)
        actionView.addSubview(moreButton)
        contentView.addSubview(lineImageView)

        let likeSize = imageDisplaySize(named: "profile_like", height: 20)
        let dislikeSize = imageDisplaySize(named: "不喜欢", height: 20)
        let moreSize = imageDisplaySize(named: "profile_more", height: 22)

        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        imageContainerView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(imageContainerView.snp.width).multipliedBy(0.5).offset(-imageSpacing / 2)
        }

        leftImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(rightImageView)
        }

        rightImageView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(leftImageView.snp.trailing).offset(imageSpacing)
            make.width.equalTo(leftImageView)
        }

        actionView.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        likeButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(likeSize == .zero ? CGSize(width: 22, height: 20) : likeSize)
        }

        likeCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(likeButton.snp.trailing).offset(6)
            make.centerY.equalTo(likeButton)
        }

        dislikeButton.snp.makeConstraints { make in
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(dislikeSize == .zero ? CGSize(width: 20, height: 20) : dislikeSize)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(moreSize == .zero ? CGSize(width: 22, height: 22) : moreSize)
        }

        lineImageView.snp.makeConstraints { make in
            make.top.equalTo(actionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }

    private let imageSpacing: CGFloat = 8

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 15)
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
        button.setImage(UIImage(named: "profile_like")?.withRenderingMode(.alwaysOriginal), for: .normal)
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
        button.setImage(UIImage(named: "不喜欢")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let lineImageView = makeImageView(named: "profile_line")

}
