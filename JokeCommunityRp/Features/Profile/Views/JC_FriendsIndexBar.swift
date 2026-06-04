//
//  JC_FriendsIndexBar.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

final class JC_FriendsIndexBar: UIView {

    var onSelectLetter: ((String) -> Void)?

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 2
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(letters: [String]) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        letters.forEach { letter in
            let button = UIButton(type: .custom)
            button.setTitle(letter, for: .normal)
            button.setTitleColor(UIColor(hex: "#333333"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.width.equalTo(18)
                make.height.equalTo(14)
            }
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func letterTapped(_ sender: UIButton) {
        guard let letter = sender.title(for: .normal) else { return }
        onSelectLetter?(letter)
    }
}
