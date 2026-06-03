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

        nicknameTextField.keyboardType = .default
        nicknameTextField.textContentType = .nickname
        nicknameTextField.autocapitalizationType = .words
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleImageView)
        view.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(cameraImageView)
        view.addSubview(nicknameTitleImageView)
        view.addSubview(nicknameFieldContainer)
        view.addSubview(continueButton)
        view.addSubview(footerContainer)

        footerContainer.addSubview(footerTextImageView)
        footerContainer.addSubview(footerActionImageView)

        let titleSize = imageDisplaySize(named: "sign_title")
        let cameraSize = imageDisplaySize(named: "info_camera")
        let nicknameTitleSize = imageDisplaySize(named: "info_nickname")
        let footerTextSize = imageDisplaySize(named: "log_have", height: 35)
        let footerActionSize = imageDisplaySize(named: "log_signin", height: 35)
        let avatarSide = max(max(cameraSize.width, cameraSize.height) * 3, 135)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(30)
            make.size.equalTo(titleSize)
        }

        avatarContainer.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(60)
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
            make.top.equalTo(avatarContainer.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(nicknameTitleSize)
        }

        nicknameFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(64)
        }

        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(64)
            make.bottom.equalTo(footerContainer.snp.top).offset(-40)
        }

        footerContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(35)
        }

        footerTextImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            if footerTextSize != .zero {
                make.width.equalTo(footerTextSize.width)
            }
        }

        footerActionImageView.snp.makeConstraints { make in
            make.leading.equalTo(footerTextImageView.snp.trailing).offset(footerTextSize == .zero ? 0 : 6)
            make.trailing.top.bottom.equalToSuperview()
            if footerActionSize != .zero {
                make.width.equalTo(footerActionSize.width)
            }
        }

        avatarContainer.layer.cornerRadius = avatarSide / 2
        footerTextImageView.isHidden = footerTextImageView.image == nil
        updateAvatarPlaceholder()
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(clickContinue), for: .touchUpInside)
        avatarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickAvatar)))
        footerContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickFooter)))
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func clickAvatar() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func clickContinue() {
        view.endEditing(true)
        let nickname = nicknameTextField.text ?? ""
        guard !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view.makeToast("Please enter a nickname")
            return
        }

        JC_CurrentUser.shared.loginWithRegistration(
            email: email,
            password: password,
            nickname: nickname,
            avatar: avatarImageView.image
        )
        JC_CurrentUser.shared.showMainInterface(in: view.window)
    }

    @objc private func clickFooter() {
        navigationController?.pushViewController(JC_SigninVC(pageType: .login), animated: true)
    }

    @objc private func textFieldDidChange() {
        nicknamePlaceholderView.isHidden = !(nicknameTextField.text?.isEmpty ?? true)
    }

    private func updateAvatarPlaceholder() {
        cameraImageView.isHidden = avatarImageView.image != nil
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

    private let titleImageView = makeImageView(named: "sign_title")

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
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

    private let continueButton = makeAssetButton(imageName: "contine_button")

    private let footerContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private let footerTextImageView = makeImageView(named: "sign_have")

    private let footerActionImageView = makeImageView(named: "sign_login")

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
