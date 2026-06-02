//
//  JC_EditVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_EditVC: JC_BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        prefillContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            (tabBarController as? JC_TabbarVC)?.setCustomTabBarHidden(false)
        }
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(cameraImageView)
        contentView.addSubview(nicknameTitleImageView)
        contentView.addSubview(nicknameFieldContainer)
        contentView.addSubview(signatureTitleLabel)
        contentView.addSubview(signatureFieldContainer)
        contentView.addSubview(genderTitleLabel)
        contentView.addSubview(genderFieldContainer)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(69)
            make.height.equalTo(29)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-30)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        let cameraSize = imageDisplaySize(named: "info_camera")
        let nicknameTitleSize = imageDisplaySize(named: "info_nickname")
        let avatarSide: CGFloat = 120

        avatarContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
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
            make.top.equalTo(avatarContainer.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.size.equalTo(nicknameTitleSize == .zero ? CGSize(width: 120, height: 24) : nicknameTitleSize)
        }

        nicknameFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(64)
        }

        signatureTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameFieldContainer.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
        }

        signatureFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(signatureTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(64)
        }

        genderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(signatureFieldContainer.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
        }

        genderFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().offset(-40)
        }

        avatarContainer.layer.cornerRadius = avatarSide / 2
        styleInputContainer(nicknameFieldContainer)
        styleInputContainer(signatureFieldContainer)
        styleInputContainer(genderFieldContainer)
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        avatarContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(clickAvatar))
        )

        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        signatureTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        genderTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func prefillContent() {
        nicknameTextField.text = "Angela"
        signatureTextField.text = "This is my first time sharing a joke, I ......."
        genderTextField.text = "Female"
        updatePlaceholderVisibility()
    }

    private func styleInputContainer(_ container: UIView) {
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(hex: "#333333").cgColor
    }

    private func updatePlaceholderVisibility() {
        nicknamePlaceholderView.isHidden = !(nicknameTextField.text?.isEmpty ?? true)
        signaturePlaceholderView.isHidden = !(signatureTextField.text?.isEmpty ?? true)
        genderPlaceholderView.isHidden = !(genderTextField.text?.isEmpty ?? true)
        cameraImageView.isHidden = avatarImageView.image != nil
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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderVisibility()
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "EDIT PROFILE"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
            ?? UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private let contentView = UIView()

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

    private let cameraImageView: UIImageView = {
        let imageView = makeImageView(named: "info_camera")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nicknameTitleImageView: UIImageView = {
        let imageView = makeImageView(named: "info_nickname")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let signatureTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "SIGNATURE"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 22)
            ?? UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()

    private let genderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "GENDER"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 22)
            ?? UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()

    private lazy var nicknameField = makeEditInputField()
    private lazy var signatureField = makeEditInputField()
    private lazy var genderField = makeEditInputField()

    private var nicknameFieldContainer: UIView { nicknameField.container }
    private var nicknameTextField: UITextField { nicknameField.textField }
    private var nicknamePlaceholderView: UIImageView { nicknameField.placeholderView }

    private var signatureFieldContainer: UIView { signatureField.container }
    private var signatureTextField: UITextField { signatureField.textField }
    private var signaturePlaceholderView: UIImageView { signatureField.placeholderView }

    private var genderFieldContainer: UIView { genderField.container }
    private var genderTextField: UITextField { genderField.textField }
    private var genderPlaceholderView: UIImageView { genderField.placeholderView }

    private func makeEditInputField() -> (container: UIView, textField: UITextField, placeholderView: UIImageView) {
        let field = makeInputField()
        field.textField.keyboardType = .default
        field.textField.autocapitalizationType = .sentences
        field.textField.textContentType = nil
        return field
    }

}

extension JC_EditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            avatarImageView.image = image
            updatePlaceholderVisibility()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}
