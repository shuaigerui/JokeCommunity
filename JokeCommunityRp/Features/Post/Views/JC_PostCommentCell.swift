//
//  JC_PostCommentCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PostCommentCell: UITableViewCell {

    static let reuseIdentifier = "JC_PostCommentCell"

    var onMoreTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onMoreTapped = nil
    }

    func configure(with comment: JC_PostComment) {
        nameLabel.text = comment.userName
        contentLabel.text = comment.content
        avatarImageView.image = comment.avatar
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(contentLabel)
        cardView.addSubview(moreButton)
        
        moreButton.addTarget(self, action: #selector(clickMoreButton), for: .touchUpInside)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-12)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.size.equalTo(44)
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.size.equalTo(22)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-12)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    @objc private func clickMoreButton() {
        onMoreTapped?()
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CDFC92")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = UIColor(hex: "#333333")
        label.numberOfLines = 0
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "post_report"), for: .normal)
        return button
    }()

}
