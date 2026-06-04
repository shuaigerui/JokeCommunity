//
//  JC_SettingVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_SettingVC: JC_BaseVC {

    private let menuItems: [String] = [
        "setting_backlist",
        "setting_privacy",
        "setting_agree",
        "setting_del"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(clickLogout), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(menuStackView)
        view.addSubview(logoutButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(69)
            make.height.equalTo(29)
        }

        menuStackView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        logoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.height.equalTo(64)
        }

        menuItems.enumerated().forEach { index, imageName in
            let button = makeMenuButton(imageName: imageName)
            if imageName == "setting_backlist" {
                button.addTarget(self, action: #selector(clickBlacklist), for: .touchUpInside)
            } else if imageName == "setting_privacy" {
                button.addTarget(self, action: #selector(clickPrivacy), for: .touchUpInside)
            } else if imageName == "setting_agree" {
                button.addTarget(self, action: #selector(clickAgreement), for: .touchUpInside)
            } else if imageName == "setting_del" {
                button.addTarget(self, action: #selector(clickDellist), for: .touchUpInside)
            }
            menuStackView.addArrangedSubview(button)
        }
    }

    @objc private func clickBlacklist() {
        let blacklistVC = JC_BlackListVC()
        navigationController?.pushViewController(blacklistVC, animated: true)
    }

    @objc private func clickPrivacy() {
        openDocument(
            urlString: "https://docs.google.com/document/d/1_EXH4uyMBDmJuYYx2_6Bd-n2BVB1EYrenWQLYuWvP2U/edit?usp=sharing"
        )
    }

    @objc private func clickAgreement() {
        openDocument(
            urlString: "https://docs.google.com/document/d/1zsHub5Kdsmgz56SMhPKk3zrEptY2lM-ijw8VJUFhsws/edit?usp=sharing"
        )
    }

    private func openDocument(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc private func clickDellist() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? All your data including posts, likes, follows, and chats will be permanently removed. This can't be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            JC_CurrentUser.shared.deleteAccount()
            JC_CurrentUser.shared.showWelcomeInterface(in: self.view.window)
        })
        present(alert, animated: true)
    }

    @objc private func clickLogout() {
        JC_CurrentUser.shared.logout()
        JC_CurrentUser.shared.showWelcomeInterface(in: view.window)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    private func makeMenuButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(Self.resizableImage(named: "profile_coinBg"), for: .normal)

        let titleImageView = makeImageView(named: imageName)
        let arrowImageView = makeImageView(named: "profile_right")
        button.addSubview(titleImageView)
        button.addSubview(arrowImageView)

        button.snp.makeConstraints { make in
            make.height.equalTo(64)
        }

        titleImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-12)
        }

        let arrowSize = imageDisplaySize(named: "profile_right", height: 14)
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(arrowSize == .zero ? CGSize(width: 8, height: 14) : arrowSize)
        }

        return button
    }

    private static func resizableImage(named name: String) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let cap = image.size.height / 2
        return image.resizableImage(
            withCapInsets: UIEdgeInsets(top: 0, left: cap, bottom: 0, right: cap),
            resizingMode: .stretch
        )
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = makeImageView(named: "common_back")
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()

    private let menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(Self.resizableImage(named: "setting_outBg"), for: .normal)

        let titleImageView = makeImageView(named: "setting_logout")
        button.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(26)
        }
        return button
    }()

}
