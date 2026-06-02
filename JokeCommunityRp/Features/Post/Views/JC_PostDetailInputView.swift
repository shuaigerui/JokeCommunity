//
//  JC_PostDetailInputView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PostDetailInputView: UIView {

    var onSendTapped: ((String) -> Void)?

    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(inputContainerView)
        inputContainerView.addSubview(textField)
        addSubview(sendButton)

        inputContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(56)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-72)
            make.centerY.equalToSuperview()
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalTo(inputContainerView).offset(-8)
            make.centerY.equalTo(inputContainerView)
            make.size.equalTo(44)
        }
    }

    @objc private func sendTapped() {
        let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        onSendTapped?(content)
        textField.text = nil
    }

    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .jc_yellow
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true
        return view
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.italicSystemFont(ofSize: 16)
        textField.textColor = UIColor(hex: "#333333")
        textField.placeholder = "Please enter..."
        textField.returnKeyType = .send
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true

        let imageView = UIImageView(image: UIImage(named: "common_send"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        return button
    }()

}
