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
        contentView.clipsToBounds = false
        clipsToBounds = false

        contentView.addSubview(backgroundImageView)
        contentView.addSubview(coinIconImageView)
        contentView.addSubview(coinsLabel)
        contentView.addSubview(priceLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        coinIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.centerX.equalToSuperview()
            make.size.equalTo(33)
        }

        coinsLabel.snp.makeConstraints { make in
            make.top.equalTo(coinIconImageView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(coinsLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
            make.height.equalTo(20)
        }
    }

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = JC_CoinProductCell.resizableCoinBackground()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private static func resizableCoinBackground() -> UIImage? {
        guard let image = UIImage(named: "coin_bg") else { return nil }
        let cap = max((min(image.size.width, image.size.height) - 2) / 2, 8)
        return image.resizableImage(
            withCapInsets: UIEdgeInsets(top: cap, left: cap, bottom: cap, right: cap),
            resizingMode: .stretch
        )
    }

    private let coinIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_icon"))
        imageView.contentMode = .scaleAspectFill
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
