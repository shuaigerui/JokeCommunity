//
//  JC_ChatAlertView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

class JC_ChatAlertView: UIView {

    var onDismiss: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func show(in viewController: UIViewController) {
        guard let container = viewController.view else { return }
        show(on: container)
    }

    static func show(on parentView: UIView) {
        let alert = JC_ChatAlertView()
        alert.alpha = 0
        parentView.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25) {
            alert.alpha = 1
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        })
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(dimView)
        addSubview(cardImageView)
        addSubview(iconImageView)
        cardImageView.addSubview(titleImageView)
        cardImageView.addSubview(contentImageView)
        cardImageView.addSubview(getItButton)

        let cardWidth = min(UIScreen.main.bounds.width - 72, 303)
        let cardSize = Self.displaySize(named: "alert_card", fittingWidth: cardWidth)
        let iconSize = Self.displaySize(named: "alert_icon", fittingWidth: 88)
        let titleSize = Self.displaySize(named: "alert_title", fittingWidth: cardWidth * 0.55)
        let contentSize = Self.displaySize(named: "alert_content", fittingWidth: cardWidth - 48)
        let buttonSize = Self.displaySize(named: "alert_getit", fittingWidth: cardWidth - 56)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(cardSize)
        }

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalTo(cardImageView)
            make.bottom.equalTo(cardImageView.snp.top).offset(iconSize.height * 0.42)
            make.size.equalTo(iconSize)
        }

        titleImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
            make.size.equalTo(titleSize)
        }

        contentImageView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.size.equalTo(contentSize)
        }

        getItButton.snp.makeConstraints { make in
            make.top.equalTo(contentImageView.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.size.equalTo(buttonSize)
            make.bottom.lessThanOrEqualToSuperview().offset(-24)
        }
    }

    private func bindActions() {
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)
        getItButton.addTarget(self, action: #selector(getItTapped), for: .touchUpInside)
    }

    @objc private func dimTapped() {
        dismiss()
    }

    @objc private func getItTapped() {
        dismiss()
    }

    private static func displaySize(named name: String, fittingWidth width: CGFloat) -> CGSize {
        guard let image = UIImage(named: name), image.size.width > 0 else {
            return CGSize(width: width, height: width * 0.5)
        }
        let ratio = image.size.height / image.size.width
        return CGSize(width: width, height: width * ratio)
    }

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()

    private let cardImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "alert_card"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "alert_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "alert_title"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let contentImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "alert_content"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let getItButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = UIImageView(image: UIImage(named: "alert_getit"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()

}
