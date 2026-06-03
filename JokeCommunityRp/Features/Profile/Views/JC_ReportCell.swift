//
//  JC_ReportCell.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit

struct JC_ReportOption {
    let imageName: String
}

class JC_ReportCell: UITableViewCell {

    static let reuseIdentifier = "JC_ReportCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(option: JC_ReportOption, isSelected: Bool) {
        bgImageView.image = UIImage(named: isSelected ? "report_bg_sel" : "report_bg")
        reasonImageView.image = UIImage(named: option.imageName)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(bgImageView)
        contentView.addSubview(reasonImageView)

        bgImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }

        reasonImageView.snp.makeConstraints { make in
            make.center.equalTo(bgImageView)
        }
    }

    private let bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let reasonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

}
