//
//  JC_CoinsHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_CoinsHeaderView: UIView {

    static let headerHeight: CGFloat = 250

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
        clipsToBounds = true

        addSubview(cardView)
        addSubview(titleBannerImageView)
        titleBannerImageView.addSubview(coinImageView)
        titleBannerImageView.addSubview(titleView)
        cardView.addSubview(balanceLabel)
        cardView.addSubview(firstTaskView)
        cardView.addSubview(secondTaskView)

        firstTaskView.addSubview(firstLikeImageView)
        firstTaskView.addSubview(firstTaskLabel)
        secondTaskView.addSubview(secondLikeImageView)
        secondTaskView.addSubview(secondTaskLabel)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(65)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(170)
        }

        titleBannerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(19)
            make.height.equalTo(102)
            make.width.equalTo(284)
        }
        
        coinImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(39)
            make.leading.equalToSuperview().offset(46)
            make.height.width.equalTo(33)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(29)
            make.leading.equalTo(coinImageView.snp.trailing).offset(12)
            make.height.equalTo(40)
            make.width.equalTo(133)
        }

        balanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(33)
        }

        firstTaskView.snp.makeConstraints { make in
            make.top.equalTo(balanceLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(33)
        }

        firstLikeImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(27)
        }

        firstTaskLabel.snp.makeConstraints { make in
            make.leading.equalTo(firstLikeImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(firstLikeImageView)
        }

        secondTaskView.snp.makeConstraints { make in
            make.top.equalTo(firstTaskView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(33)
        }

        secondLikeImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(27)
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
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "#707070").cgColor
        return view
    }()

    private let titleBannerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_titleBg"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_icon"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_title"))
        imageView.contentMode = .scaleAspectFill
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
