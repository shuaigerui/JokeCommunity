//
//  JC_CoinProductCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_CoinProductCell: UICollectionViewCell {

    static let reuseIdentifier = "JC_CoinProductCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with product: JC_CoinProduct) {
        coinsLabel.text = product.coins
        priceLabel.text = product.price
    }

    private func setupUI() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(coinIconImageView)
        contentView.addSubview(coinsLabel)
        contentView.addSubview(priceLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        coinIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.size.equalTo(28)
        }

        coinsLabel.snp.makeConstraints { make in
            make.top.equalTo(coinIconImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(coinsLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "coin_bg") {
            let cap = min(image.size.width, image.size.height) / 2
            imageView.image = image.resizableImage(
                withCapInsets: UIEdgeInsets(top: cap, left: cap, bottom: cap, right: cap),
                resizingMode: .stretch
            )
        }
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let coinIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let coinsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

}
