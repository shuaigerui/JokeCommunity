//
//  JC_UIHelper.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

func makeImageButton(imageName: String, contentInsets: UIEdgeInsets) -> UIButton {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hex: "#FFCC00")
    button.layer.cornerRadius = 32
    button.layer.masksToBounds = true

    let imageView = UIImageView(image: UIImage(named: imageName))
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = false
    button.addSubview(imageView)
    imageView.snp.makeConstraints { make in
        make.edges.equalToSuperview().inset(contentInsets)
    }

    return button
}

func makeInputField(isSecure: Bool = false) -> (container: UIView, textField: UITextField, placeholderView: UIImageView) {
    let container = UIView()
    container.backgroundColor = UIColor(hex: "#FFCC00")
    container.layer.cornerRadius = 24
    container.layer.masksToBounds = true

    let placeholderView = UIImageView(image: UIImage(named: "enter_title"))
    placeholderView.contentMode = .scaleAspectFit

    let textField = UITextField()
    textField.font = UIFont.italicSystemFont(ofSize: 16)
    textField.textColor = UIColor(hex: "#333333")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.isSecureTextEntry = isSecure
    if isSecure {
        textField.textContentType = .password
    } else {
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
    }

    container.addSubview(placeholderView)
    container.addSubview(textField)

    placeholderView.snp.makeConstraints { make in
        make.leading.equalToSuperview().offset(24)
        make.centerY.equalToSuperview()
        make.height.equalTo(24)
        make.width.lessThanOrEqualToSuperview().offset(-48)
    }

    textField.snp.makeConstraints { make in
        make.leading.equalToSuperview().offset(24)
        make.trailing.equalToSuperview().offset(-24)
        make.top.bottom.equalToSuperview()
    }

    return (container, textField, placeholderView)
}

func imageDisplaySize(named name: String, height: CGFloat? = nil) -> CGSize {
    guard let image = UIImage(named: name), image.size.height > 0 else { return .zero }
    let displayHeight = height ?? image.size.height
    let displayWidth = image.size.width / image.size.height * displayHeight
    return CGSize(width: displayWidth, height: displayHeight)
}

func makeAssetButton(imageName: String) -> UIButton {
    let button = UIButton(type: .custom)
    let imageView = UIImageView(image: UIImage(named: imageName))
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = false
    button.addSubview(imageView)
    imageView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
    }
    return button
}

func makeImageView(named name: String) -> UIImageView {
    let imageView = UIImageView()
    imageView.image = UIImage(named: name)
    imageView.contentMode = .scaleAspectFill
    return imageView
}
