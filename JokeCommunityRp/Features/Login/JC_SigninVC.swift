//
//  JC_SigninVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import Toast_Swift

enum JC_SignPageType {
    case signup
    case login

    var titleImageName: String {
        switch self {
        case .signup: return "sign_title"
        case .login: return "log_title"
        }
    }

    var footerTextImageName: String {
        switch self {
        case .signup: return "sign_have"
        case .login: return "log_have"
        }
    }

    var footerActionImageName: String {
        switch self {
        case .signup: return "sign_login"
        case .login: return "log_signup"
        }
    }

    var toggled: JC_SignPageType {
        switch self {
        case .signup: return .login
        case .login: return .signup
        }
    }
}

class JC_SigninVC: JC_BaseVC {

    private var pageType: JC_SignPageType

    init(pageType: JC_SignPageType) {
        self.pageType = pageType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePageContent()
        bindActions()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleImageView)
        view.addSubview(emailTitleImageView)
        view.addSubview(emailFieldContainer)
        view.addSubview(passwordTitleImageView)
        view.addSubview(passwordFieldContainer)
        view.addSubview(continueButton)
        view.addSubview(footerContainer)

        footerContainer.addSubview(footerTextImageView)
        footerContainer.addSubview(footerActionImageView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(69)
            make.height.equalTo(29)
        }

        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(46)
            make.leading.equalToSuperview().offset(30)
        }

        emailTitleImageView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(104)
            make.leading.equalToSuperview().offset(31)
        }

        emailFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(emailTitleImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(48)
        }

        passwordTitleImageView.snp.makeConstraints { make in
            make.top.equalTo(emailFieldContainer.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
        }

        passwordFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(passwordTitleImageView.snp.bottom).offset(27)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(48)
        }

        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalTo(footerContainer.snp.top).offset(-40)
        }

        footerContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(35)
            make.width.lessThanOrEqualToSuperview().offset(-40)
        }

        footerTextImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        footerActionImageView.snp.makeConstraints { make in
            make.leading.equalTo(footerTextImageView.snp.trailing).offset(9)
            make.trailing.top.bottom.equalToSuperview()
        }
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        footerContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickFooter)))
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        continueButton.addTarget(self, action: #selector(clickContinue), for: .touchUpInside)
    }

    private func updatePageContent() {
        titleImageView.image = UIImage(named: pageType.titleImageName)

        footerTextImageView.image = UIImage(named: pageType.footerTextImageName)
        footerActionImageView.image = UIImage(named: pageType.footerActionImageName)

        let hasFooterText = footerTextImageView.image != nil
        footerTextImageView.isHidden = !hasFooterText
        footerActionImageView.snp.updateConstraints { make in
            make.leading.equalTo(footerTextImageView.snp.trailing).offset(hasFooterText ? 6 : 0)
        }
    }
    
    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clickContinue() {
        view.endEditing(true)
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        switch pageType {
        case .signup:
            navigationController?.pushViewController(
                JC_SetupInfoVC(email: email, password: password),
                animated: true
            )
        case .login:
            if JC_CurrentUser.shared.login(email: email, password: password) {
                JC_CurrentUser.shared.showMainInterface(in: view.window)
            } else {
                view.makeToast("Invalid email or password")
            }
        }
    }

    @objc private func clickFooter() {
        pageType = pageType.toggled
        updatePageContent()
    }

    @objc private func textFieldDidChange() {
        emailPlaceholderView.isHidden = !(emailTextField.text?.isEmpty ?? true)
        passwordPlaceholderView.isHidden = !(passwordTextField.text?.isEmpty ?? true)
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = UIImageView(image: UIImage(named: "common_back"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emailTitleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "email_title"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let passwordTitleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "password_title"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var emailField = makeInputField()
    private lazy var passwordField = makeInputField(isSecure: true)

    private var emailFieldContainer: UIView { emailField.container }
    private var emailTextField: UITextField { emailField.textField }
    private var emailPlaceholderView: UIImageView { emailField.placeholderView }

    private var passwordFieldContainer: UIView { passwordField.container }
    private var passwordTextField: UITextField { passwordField.textField }
    private var passwordPlaceholderView: UIImageView { passwordField.placeholderView }

    private let continueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "contine_button"), for: .normal)
        return button
    }()

    private let footerContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private let footerTextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let footerActionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

}
