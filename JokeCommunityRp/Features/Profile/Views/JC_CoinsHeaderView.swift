//
//  JC_CoinsHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_CoinsHeaderView: UIView {

    static let headerHeight: CGFloat = 220

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configure(balance: "9999")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(balance: String) {
        balanceLabel.text = "Balance: \(balance)"
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(cardView)
        addSubview(titleBannerImageView)
        cardView.addSubview(balanceLabel)
        cardView.addSubview(firstTaskView)
        cardView.addSubview(secondTaskView)

        firstTaskView.addSubview(firstLikeImageView)
        firstTaskView.addSubview(firstTaskLabel)
        secondTaskView.addSubview(secondLikeImageView)
        secondTaskView.addSubview(secondTaskLabel)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview()
        }

        titleBannerImageView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.top).offset(-28)
            make.centerX.equalTo(cardView)
            make.height.equalTo(56)
            make.width.lessThanOrEqualToSuperview().offset(-40)
        }

        balanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        firstTaskView.snp.makeConstraints { make in
            make.top.equalTo(balanceLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        firstLikeImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(18)
        }

        firstTaskLabel.snp.makeConstraints { make in
            make.leading.equalTo(firstLikeImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(firstLikeImageView)
        }

        secondTaskView.snp.makeConstraints { make in
            make.top.equalTo(firstTaskView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
        }

        secondLikeImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(18)
        }

        secondTaskLabel.snp.makeConstraints { make in
            make.leading.equalTo(secondLikeImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(secondLikeImageView)
        }
    }

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    private let titleBannerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_titleBg"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let firstTaskView = UIView()
    private let secondTaskView = UIView()

    private let firstLikeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_like"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let secondLikeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_like"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let firstTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "*publish an article*"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let secondTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "*Publish featured videos*"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

}
