//
//  JC_HomePostView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers

enum JC_HomePostMedia {
    case none
    case video(URL)
    case images([UIImage])
}

final class JC_HomePostView: UIView {

    weak var hostViewController: UIViewController?

    var onDismiss: (() -> Void)?
    var onRelease: ((String, JC_HomePostMedia) -> Void)?

    private var media: JC_HomePostMedia = .none
    private var replacingImageIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(in view: UIView, animated: Bool) {
        frame = view.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alpha = 0
        view.addSubview(self)

        panelView.transform = CGAffineTransform(translationX: 0, y: 420)
        guard animated else {
            alpha = 1
            panelView.transform = .identity
            return
        }
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.panelView.transform = .identity
        }
    }

    func dismiss(animated: Bool = true) {
        let finish = { [weak self] in
            self?.removeFromSuperview()
            self?.onDismiss?()
        }
        guard animated else {
            finish()
            return
        }
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn) {
            self.alpha = 0
            self.panelView.transform = CGAffineTransform(translationX: 0, y: 420)
        } completion: { _ in
            finish()
        }
    }

    private func setupUI() {
        addSubview(dimView)
        addSubview(panelView)

        panelView.addSubview(titleView)
        panelView.addSubview(textContainerView)
        textContainerView.addSubview(textView)
        textContainerView.addSubview(placeholderLabel)
        panelView.addSubview(mediaContainerView)
        mediaContainerView.addSubview(addMediaButton)
        mediaContainerView.addSubview(rightSlotView)
        mediaContainerView.addSubview(leftImageView)
        mediaContainerView.addSubview(rightImageView)
        mediaContainerView.addSubview(videoPreviewImageView)
        mediaContainerView.addSubview(playIconView)
        panelView.addSubview(releaseButton)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        panelView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.68)
        }

        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }

        textContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(125)
        }

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        mediaContainerView.snp.makeConstraints { make in
            make.top.equalTo(textContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(255)
        }

        addMediaButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(56)
        }

        rightSlotView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(12)
            make.leading.equalTo(leftImageView.snp.trailing).offset(12)
            make.width.equalTo(leftImageView)
        }

        leftImageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(12)
            make.width.equalTo(rightSlotView)
        }

        rightImageView.snp.makeConstraints { make in
            make.edges.equalTo(rightSlotView)
        }

        videoPreviewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        playIconView.snp.makeConstraints { make in
            make.center.equalTo(videoPreviewImageView)
            make.size.equalTo(44)
        }

        releaseButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-28)
            make.height.equalTo(64)
        }

        updateMediaDisplay()
    }

    private func bindActions() {
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimTapped)))
        addMediaButton.addTarget(self, action: #selector(addMediaTapped), for: .touchUpInside)
        releaseButton.addTarget(self, action: #selector(releaseTapped), for: .touchUpInside)
        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftImageTapped)))
        rightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightImageTapped)))
        videoPreviewImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoPreviewTapped)))
        textView.delegate = self
    }

    @objc private func dimTapped() {
        dismiss()
    }

    @objc private func addMediaTapped() {
        guard let hostViewController else { return }

        if case .images(let images) = media, images.count == 1 {
            presentImagePicker(from: hostViewController)
            return
        }

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Video", style: .default) { [weak self] _ in
            self?.presentVideoPicker(from: hostViewController)
        })
        sheet.addAction(UIAlertAction(title: "Photos", style: .default) { [weak self] _ in
            self?.presentImagePicker(from: hostViewController)
        })
        if case .none = media {} else {
            sheet.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                self?.clearMedia()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        hostViewController.present(sheet, animated: true)
    }

    @objc private func leftImageTapped() {
        guard let hostViewController, case .images = media else { return }
        presentImagePicker(from: hostViewController, replacingIndex: 0)
    }

    @objc private func rightImageTapped() {
        guard let hostViewController, case .images(let images) = media, images.count > 1 else { return }
        presentImagePicker(from: hostViewController, replacingIndex: 1)
    }

    @objc private func videoPreviewTapped() {
        guard let hostViewController, case .video = media else { return }
        presentVideoPicker(from: hostViewController)
    }

    @objc private func releaseTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        onRelease?(text, media)
        dismiss()
    }

    private func presentVideoPicker(from controller: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [UTType.movie.identifier]
        picker.delegate = self
        picker.videoQuality = .typeMedium
        controller.present(picker, animated: true)
    }

    private func presentImagePicker(from controller: UIViewController, replacingIndex: Int? = nil) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        replacingImageIndex = replacingIndex
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [UTType.image.identifier]
        picker.delegate = self
        controller.present(picker, animated: true)
    }

    private func clearMedia() {
        media = .none
        updateMediaDisplay()
    }

    private func setVideo(_ url: URL) {
        media = .video(url)
        updateMediaDisplay()
        videoPreviewImageView.image = generateVideoThumbnail(url: url)
    }

    private func appendImage(_ image: UIImage) {
        switch media {
        case .none:
            media = .images([image])
        case .images(var images):
            guard images.count < 2 else { return }
            images.append(image)
            media = .images(images)
        case .video:
            media = .images([image])
        }
        updateMediaDisplay()
    }

    private func replaceImage(at index: Int, with image: UIImage) {
        guard case .images(var images) = media, images.indices.contains(index) else { return }
        images[index] = image
        media = .images(images)
        updateMediaDisplay()
    }

    private func updateMediaDisplay() {
        addMediaButton.isHidden = false
        leftImageView.isHidden = true
        rightImageView.isHidden = true
        rightSlotView.isHidden = true
        videoPreviewImageView.isHidden = true
        playIconView.isHidden = true
        updateAddMediaButtonPlacement(.center)

        switch media {
        case .none:
            break
        case .video:
            addMediaButton.isHidden = true
            videoPreviewImageView.isHidden = false
            playIconView.isHidden = false
        case .images(let images):
            if images.count == 2 {
                addMediaButton.isHidden = true
            } else if images.count == 1 {
                updateAddMediaButtonPlacement(.rightSlot)
            } else {
                addMediaButton.isHidden = false
            }

            if images.indices.contains(0) {
                leftImageView.isHidden = false
                leftImageView.image = images[0]
            }
            if images.indices.contains(1) {
                rightImageView.isHidden = false
                rightImageView.image = images[1]
            }
            rightSlotView.isHidden = images.count != 1
        }

        if !addMediaButton.isHidden {
            mediaContainerView.bringSubviewToFront(addMediaButton)
        }
    }

    private enum AddMediaButtonPlacement {
        case center
        case rightSlot
    }

    private func updateAddMediaButtonPlacement(_ placement: AddMediaButtonPlacement) {
        addMediaButton.snp.remakeConstraints { make in
            make.size.equalTo(56)
            switch placement {
            case .center:
                make.center.equalToSuperview()
            case .rightSlot:
                make.center.equalTo(rightSlotView)
            }
        }
    }

    private func generateVideoThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func updatePlaceholder() {
        placeholderLabel.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()

    private let panelView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_postBg")
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()

    private let titleView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "home_postTitle")
        v.contentMode = .scaleAspectFill
        return v
    }()

    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.italicSystemFont(ofSize: 16)
        textView.textColor = UIColor(hex: "#333333")
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Write jokes........."
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#999999")
        return label
    }()

    private let mediaContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var addMediaButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .thin)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(hex: "#CCCCCC")
        return button
    }()

    private let rightSlotView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let videoPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let playIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        imageView.image = UIImage(systemName: "play.circle.fill", withConfiguration: config)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let releaseButton: UIButton = {
        let button = makeAssetButton(imageName: "home_release")
        return button
    }()

}

extension JC_HomePostView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
    }

}

extension JC_HomePostView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        replacingImageIndex = nil
        picker.dismiss(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        if let mediaURL = info[.mediaURL] as? URL {
            replacingImageIndex = nil
            setVideo(mediaURL)
            return
        }

        if let image = info[.originalImage] as? UIImage {
            if let index = replacingImageIndex {
                replaceImage(at: index, with: image)
            } else {
                appendImage(image)
            }
        }
        replacingImageIndex = nil
    }

}
