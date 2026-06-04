//
//  JC_FriendsSectionHeaderView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

final class JC_FriendsSectionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "JC_FriendsSectionHeaderView"

    func configure(title: String) {
        titleLabel.text = title
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textColor = UIColor(hex: "#999999")
        return label
    }()
}
