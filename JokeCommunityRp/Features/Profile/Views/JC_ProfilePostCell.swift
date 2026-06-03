//
//  JC_ProfilePostCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ProfilePostCell: UITableViewCell {

    static let reuseIdentifier = "JC_ProfilePostCell"

    private var usesFullWidthImageLayout = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applySplitImageLayout()
        leftImageView.image = nil
        rightImageView.image = nil
    }

    func configure(with post: JC_ProfilePost) {
        contentLabel.text = post.content
        likeCountLabel.text = post.likeCount

        if post.isVideo {
            applyFullWidthImageLayout()
            leftImageView.image = post.images.first ?? nil
            rightImageView.isHidden = true
            rightImageView.image = nil
            return
        }

        applySplitImageLayout()
        leftImageView.image = post.images.first ?? nil
        let hasSecondImage = post.images.count > 1
        rightImageView.isHidden = !hasSecondImage
        rightImageView.image = hasSecondImage ? post.images[1] : nil
    }

    private func applyFullWidthImageLayout() {
        guard !usesFullWidthImageLayout else { return }
        usesFullWidthImageLayout = true

        leftImageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func applySplitImageLayout() {
        guard usesFullWidthImageLayout else { return }
        usesFullWidthImageLayout = false

        leftImageView.snp.remakeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(rightImageView)
        }

        rightImageView.snp.remakeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(leftImageView.snp.trailing).offset(12)
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

        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
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
            make.width.equalTo(22)
            make.height.equalTo(20)
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

        moreButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        lineImageView.snp.makeConstraints { make in
            make.top.equalTo(actionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

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

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_more"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let lineImageView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

}
