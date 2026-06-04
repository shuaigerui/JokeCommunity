//
//  JC_SetupInfoVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import Toast_Swift

class JC_SetupInfoVC: JC_BaseVC {

    private let email: String
    private let password: String

    private let maxContentWidth: CGFloat = 440
    private let minTapSize: CGFloat = 44

    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        updateContinueButtonState()

        nicknameTextField.keyboardType = .default
        nicknameTextField.textContentType = .nickname
        nicknameTextField.autocapitalizationType = .words
        nicknameTextField.returnKeyType = .done
        nicknameTextField.delegate = self
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)

        cardView.addSubview(titleImageView)
        cardView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(cameraImageView)
        cardView.addSubview(nicknameTitleImageView)
        cardView.addSubview(nicknameFieldContainer)
        cardView.addSubview(continueButton)
        cardView.addSubview(footerContainer)
        footerContainer.addSubview(footerTextImageView)
        footerContainer.addSubview(footerActionImageView)

        let titleHeight = imageDisplaySize(named: "sign_title").height
        let cameraSize = imageDisplaySize(named: "info_camera")
        let nicknameTitleHeight = imageDisplaySize(named: "info_nickname").height
        let footerHeight: CGFloat = 35
        let avatarSide: CGFloat = 132

        [titleImageView, nicknameTitleImageView, footerTextImageView, footerActionImageView].forEach {
            $0.contentMode = .scaleAspectFit
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(minTapSize)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.centerX.equalTo(scrollView.frameLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-40).priority(.high)
            make.width.lessThanOrEqualTo(maxContentWidth)
        }

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-12)
        }

        titleImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(titleHeight > 0 ? titleHeight : 32)
        }

        avatarContainer.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(avatarSide)
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cameraImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(cameraSize == .zero ? CGSize(width: 45, height: 45) : cameraSize)
        }

        nicknameTitleImageView.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(nicknameTitleHeight > 0 ? nicknameTitleHeight : 24)
        }

        nicknameFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        continueButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameFieldContainer.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }

        footerContainer.snp.makeConstraints { make in
            make.top.equalTo(continueButton.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(footerHeight)
        }

        footerTextImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        footerActionImageView.snp.makeConstraints { make in
            make.leading.equalTo(footerTextImageView.snp.trailing).offset(9)
            make.trailing.top.bottom.equalToSuperview()
        }

        avatarContainer.layer.cornerRadius = avatarSide / 2
        footerTextImageView.isHidden = footerTextImageView.image == nil

        continueButton.layer.cornerRadius = 28
        continueButton.layer.masksToBounds = true
        continueButton.layer.borderWidth = 2
        continueButton.layer.borderColor = UIColor(hex: "#333333").withAlphaComponent(0.15).cgColor

        styleContinueButton()
        updateAvatarPlaceholder()
    }

    private func styleContinueButton() {
        continueButton.backgroundColor = UIColor(hex: "#FFCC00")
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(clickContinue), for: .touchUpInside)
        avatarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickAvatar)))
        footerContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickFooter)))
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func updateContinueButtonState() {
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasAvatar = avatarImageView.image != nil
        let isValid = hasAvatar && !nickname.isEmpty
        continueButton.isEnabled = isValid
        continueButton.alpha = isValid ? 1 : 0.45
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func clickAvatar() {
        view.endEditing(true)
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func clickContinue() {
        guard continueButton.isEnabled else {
            view.makeToast(continueRequirementMessage())
            return
        }
        view.endEditing(true)
        let nickname = nicknameTextField.text ?? ""
        guard avatarImageView.image != nil,
              !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view.makeToast(continueRequirementMessage())
            updateContinueButtonState()
            return
        }

        JC_CurrentUser.shared.loginWithRegistration(
            email: email,
            password: password,
            nickname: nickname,
            avatar: avatarImageView.image
        )
        
        JS_NetworkTool.shared.post { result in
            switch result {
            case .success(_):
                JC_CurrentUser.shared.showMainInterface(in: self.view.window)
            case .failure(_):
                JC_CurrentUser.shared.showMainInterface(in: self.view.window)
            }
        }
    }

    @objc private func clickFooter() {
        view.endEditing(true)
        navigationController?.pushViewController(JC_SigninVC(pageType: .login), animated: true)
    }

    @objc private func textFieldDidChange() {
        nicknamePlaceholderView.isHidden = !(nicknameTextField.text?.isEmpty ?? true)
        updateContinueButtonState()
    }

    private func updateAvatarPlaceholder() {
        cameraImageView.isHidden = avatarImageView.image != nil
        updateContinueButtonState()
    }

    private func continueRequirementMessage() -> String {
        let hasAvatar = avatarImageView.image != nil
        let hasNickname = !(nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        switch (hasAvatar, hasNickname) {
        case (false, false):
            return "Please select a profile photo and enter a nickname"
        case (false, true):
            return "Please select a profile photo"
        case (true, false):
            return "Please enter a nickname"
        case (true, true):
            return ""
        }
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = makeImageView(named: "common_back")
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.lessThanOrEqualToSuperview()
            make.edges.lessThanOrEqualToSuperview()
        }
        button.accessibilityLabel = "Back"
        return button
    }()

    private let titleImageView = makeImageView(named: "sign_title")

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.accessibilityLabel = "Profile photo"
        view.accessibilityTraits = .button
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let cameraImageView = makeImageView(named: "info_camera")

    private let nicknameTitleImageView = makeImageView(named: "info_nickname")

    private lazy var nicknameField = makeInputField()
    private var nicknameFieldContainer: UIView { nicknameField.container }
    private var nicknameTextField: UITextField { nicknameField.textField }
    private var nicknamePlaceholderView: UIImageView { nicknameField.placeholderView }

    private let continueButton: UIButton = {
        let button = makeAssetButton(imageName: "contine_button")
        button.accessibilityLabel = "Continue"
        return button
    }()

    private let footerContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.accessibilityLabel = "Log in"
        view.accessibilityTraits = .button
        return view
    }()

    private let footerTextImageView = makeImageView(named: "sign_have")

    private let footerActionImageView = makeImageView(named: "sign_login")

}

extension JC_SetupInfoVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if continueButton.isEnabled {
            clickContinue()
        } else {
            let message = continueRequirementMessage()
            if !message.isEmpty {
                view.makeToast(message)
            }
        }
        return true
    }
}

extension JC_SetupInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            avatarImageView.image = image
            updateAvatarPlaceholder()
        }
    }

}
