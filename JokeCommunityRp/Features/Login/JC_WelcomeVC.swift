//
//  JC_WelcomeVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

class JC_WelcomeVC: JC_BaseVC {

    private enum LegalURL {
        static let userAgreement = "https://docs.google.com/document/d/1zsHub5Kdsmgz56SMhPKk3zrEptY2lM-ijw8VJUFhsws/edit?usp=sharing"
        static let privacyPolicy = "https://docs.google.com/document/d/1_EXH4uyMBDmJuYYx2_6Bd-n2BVB1EYrenWQLYuWvP2U/edit?usp=sharing"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        signupButton.addTarget(self, action: #selector(clickSignupButton), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(clickLoginButton), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(clickAppleButton), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(topImageView)
        contentView.addSubview(titleImageView)
        contentView.addSubview(appleButton)
        contentView.addSubview(signupButton)
        contentView.addSubview(logInButton)
        contentView.addSubview(agreementTextView)

        scrollView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view.frame.width)
        }
        
        topImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
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

        agreementTextView.snp.makeConstraints { make in
            make.top.equalTo(signupButton.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func makeAgreementAttributedText() -> NSAttributedString {
        let fullText = "By signing up, you agree to the User Agreement & Privacy Policy"
        let userAgreementText = "User Agreement"
        let privacyPolicyText = "Privacy Policy"

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 4

        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(hex: "#666666"),
            .paragraphStyle: paragraph
        ]

        let attributed = NSMutableAttributedString(string: fullText, attributes: baseAttributes)

        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(hex: "#333333"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        if let range = fullText.range(of: userAgreementText),
           let url = URL(string: LegalURL.userAgreement) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes(linkAttributes, range: nsRange)
            attributed.addAttribute(.link, value: url, range: nsRange)
        }

        if let range = fullText.range(of: privacyPolicyText),
           let url = URL(string: LegalURL.privacyPolicy) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes(linkAttributes, range: nsRange)
            attributed.addAttribute(.link, value: url, range: nsRange)
        }

        return attributed
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

    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsVerticalScrollIndicator = false
        v.alwaysBounceVertical = true
        v.contentInsetAdjustmentBehavior = .never
        return v
    }()
    private lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
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

    private lazy var agreementTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.attributedText = makeAgreementAttributedText()
        textView.linkTextAttributes = [
            .foregroundColor: UIColor(hex: "#333333"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return textView
    }()

}

extension JC_WelcomeVC: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
