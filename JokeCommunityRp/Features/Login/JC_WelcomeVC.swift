//
//  JC_WelcomeVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

class JC_WelcomeVC: JC_BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        signupButton.addTarget(self, action: #selector(clickSignupButton), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(clickLoginButton), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(clickAppleButton), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(topImageView)
        view.addSubview(titleImageView)
        view.addSubview(appleButton)
        view.addSubview(signupButton)
        view.addSubview(logInButton)

        topImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(258)
            make.height.equalTo(295)
        }

        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(topImageView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(291)
            make.height.equalTo(141)
        }

        appleButton.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(-15)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(64)
        }

        let itemW = (view.frame.width - 60 - 9)/2
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(appleButton.snp.bottom).offset(31)
            make.leading.height.equalTo(appleButton)
            make.width.equalTo(itemW)
        }

        logInButton.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(signupButton)
            make.trailing.equalTo(appleButton)
        }
    }
    
    @objc private func clickSignupButton() {
        navigationController?.pushViewController(JC_SigninVC(pageType: .signup), animated: true)
    }

    @objc private func clickLoginButton() {
        navigationController?.pushViewController(JC_SigninVC(pageType: .login), animated: true)
    }

    @objc private func clickAppleButton() {
        JC_CurrentUser.shared.loginWithApple()
        JC_CurrentUser.shared.showMainInterface(in: view.window)
    }

    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "welcome_top")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "welcomr_title")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let appleButton: UIButton = {
        makeImageButton(imageName: "apple_title", contentInsets: UIEdgeInsets(top: 18, left: 60, bottom: 18, right: 60))
    }()

    private let signupButton: UIButton = {
        makeImageButton(imageName: "signup_title", contentInsets: UIEdgeInsets(top: 17, left: 40, bottom: 17, right: 40))
    }()

    private let logInButton: UIButton = {
        makeImageButton(imageName: "login_title", contentInsets: UIEdgeInsets(top: 17, left: 40, bottom: 17, right: 40))
    }()

}
