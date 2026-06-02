//
//  JC_ChatRoomInputView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ChatRoomInputView: UIView {

    var onSendTapped: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        textField.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(inputContainerView)
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(sendButton)

        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(56)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(46)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func sendTapped() {
        sendCurrentText()
    }

    private func sendCurrentText() {
        let content = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
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
        button.setImage(UIImage(named: "common_send"), for: .normal)
        return button
    }()

}

extension JC_ChatRoomInputView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCurrentText()
        return true
    }

}
