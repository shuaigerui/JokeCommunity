//
//  JC_TabbarVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

enum DS_TabbarType: CaseIterable {
    case home
    case post
    case chat
    case profile

    var imageName: String {
        switch self {
        case .home:
            return "tab_home"
        case .post:
            return "tab_post"
        case .chat:
            return "tab_chat"
        case .profile:
            return "tab_profile"
        }
    }

    var selImageName: String {
        "\(imageName)_sel"
    }

    var controller: UIViewController {
        switch self {
        case .home:
            return UINavigationController(rootViewController: JC_HomeVC())
        case .post:
            return UINavigationController(rootViewController: JC_PostVC())
        case .chat:
            return UINavigationController(rootViewController: JC_ChatVC())
        case .profile:
            return UINavigationController(rootViewController: JC_ProfileVC())
        }
    }
}

final class JC_CustomTabBarView: UIView {

    var onSelect: ((Int) -> Void)?

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "tab_bg") {
            let cap = image.size.height / 2
            imageView.image = image.resizableImage(
                withCapInsets: UIEdgeInsets(top: 0, left: cap, bottom: 0, right: cap),
                resizingMode: .stretch
            )
        }
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()

    private var itemButtons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(backgroundImageView)
        addSubview(stackView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }

        DS_TabbarType.allCases.enumerated().forEach { index, type in
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: type.imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.setImage(UIImage(named: type.selImageName)?.withRenderingMode(.alwaysOriginal), for: .selected)
            button.adjustsImageWhenHighlighted = false
            button.tag = index
            button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            itemButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        selectItem(at: 0, notify: false)
    }

    func selectItem(at index: Int, notify: Bool = true) {
        guard itemButtons.indices.contains(index) else { return }
        itemButtons.enumerated().forEach { idx, button in
            button.isSelected = idx == index
        }
        if notify {
            onSelect?(index)
        }
    }

    @objc private func itemTapped(_ sender: UIButton) {
        selectItem(at: sender.tag)
    }
}

class JC_TabbarVC: UITabBarController {

    private let customTabBar = JC_CustomTabBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupCustomTabBar()
        selectedIndex = 0
        customTabBar.selectItem(at: 0, notify: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInset()
    }

    private func setupViewControllers() {
        viewControllers = DS_TabbarType.allCases.map { $0.controller }
    }

    private func setupCustomTabBar() {
        tabBar.isHidden = true

        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-6)
            make.height.equalTo(60)
        }

        customTabBar.onSelect = { [weak self] index in
            self?.selectedIndex = index
        }
    }

    private func updateContentInset() {
        let bottomInset = customTabBar.frame.height + 12
        viewControllers?.forEach { controller in
            controller.additionalSafeAreaInsets.bottom = bottomInset
        }
    }

}
