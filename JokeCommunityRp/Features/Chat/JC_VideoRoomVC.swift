//
//  JC_VideoRoomVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit
import AVFoundation

class JC_VideoRoomVC: JC_BaseVC {

    private let peerUserId: String
    private let roomTitle: String

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var isMicMuted = false
    private var isSpeakerMuted = false

    init(peerUserId: String, roomTitle: String? = nil) {
        self.peerUserId = peerUserId
        if let roomTitle, !roomTitle.isEmpty {
            self.roomTitle = roomTitle
        } else {
            let name = JC_UserData.resolvedUser(userId: peerUserId)?.nickname ?? "VIDEO"
            self.roomTitle = name.uppercased()
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func presentFrom(
        _ viewController: UIViewController,
        peerUserId: String,
        roomTitle: String? = nil
    ) {
        JC_MediaPermission.ensureVideoCallPermissions(on: viewController) { granted in
            guard granted else { return }
            let roomVC = JC_VideoRoomVC(peerUserId: peerUserId, roomTitle: roomTitle)
            viewController.navigationController?.pushViewController(roomVC, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = .black
        
        JS_NetworkTool.shared.post(isShow: false) { result in
            switch result {
            case .success(_): break

            case .failure(_): break

            }
        }
        
        setupUI()
        bindActions()
        configurePeerAvatar()
        startCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            stopCamera()
        }
    }

    private func configurePeerAvatar() {
        peerAvatarImageView.image = JC_UserData.resolvedUser(userId: peerUserId)?.avatar
        loadingIndicator.startAnimating()
    }

    private func setupUI() {
        titleLabel.text = roomTitle

        view.insertSubview(previewView, at: 0)
        view.addSubview(navBarView)
        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)

        view.addSubview(avatarContainerView)
        avatarContainerView.addSubview(avatarBgImageView)
        avatarContainerView.addSubview(peerAvatarImageView)
        avatarContainerView.addSubview(loadingIndicator)
        view.addSubview(bottomBarImageView)
        view.addSubview(voiceButton)
        view.addSubview(hangUpButton)
        view.addSubview(micButton)

        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        avatarContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(168)
        }

        avatarBgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        peerAvatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(120)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(peerAvatarImageView)
        }

        let menuHeight = max(imageDisplaySize(named: "video_menuBg").height, 88)
        bottomBarImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(menuHeight)
        }

        hangUpButton.snp.makeConstraints { make in
            make.centerX.equalTo(bottomBarImageView)
            make.centerY.equalTo(bottomBarImageView).offset(-6)
            make.size.equalTo(imageDisplaySize(named: "video_off", height: 72))
        }

        voiceButton.snp.makeConstraints { make in
            make.centerY.equalTo(bottomBarImageView)
            make.trailing.equalTo(hangUpButton.snp.leading).offset(-28)
            make.size.equalTo(imageDisplaySize(named: "video_voice", height: 52))
        }

        micButton.snp.makeConstraints { make in
            make.centerY.equalTo(bottomBarImageView)
            make.leading.equalTo(hangUpButton.snp.trailing).offset(28)
            make.size.equalTo(imageDisplaySize(named: "video_mic", height: 52))
        }

        updateControlButtons()
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        hangUpButton.addTarget(self, action: #selector(clickHangUp), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(toggleVoice), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
    }

    private func startCamera() {
        guard JC_MediaPermission.isFullyAuthorized else { return }

        if captureSession.inputs.isEmpty {
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .high

            if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
               let cameraInput = try? AVCaptureDeviceInput(device: camera),
               captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }

            if let microphone = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: microphone),
               captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }

            captureSession.commitConfiguration()

            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            previewView.layer.insertSublayer(layer, at: 0)
            previewLayer = layer
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    private func stopCamera() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    private func updateControlButtons() {
        let voiceImage = isSpeakerMuted ? "video_voice_off" : "video_voice"
        let micImage = isMicMuted ? "video_mic_off" : "video_mic"
        voiceButton.setImage(UIImage(named: voiceImage), for: .normal)
        micButton.setImage(UIImage(named: micImage), for: .normal)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func clickHangUp() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func toggleVoice() {
        isSpeakerMuted.toggle()
        updateControlButtons()
    }

    @objc private func toggleMic() {
        isMicMuted.toggle()
        updateControlButtons()
    }

    private let previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let navBarView = UIView()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = makeImageView(named: "common_back")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
            ?? UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()

    private let avatarContainerView = UIView()

    private let avatarBgImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "video_avatarBg"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let peerAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = UIColor(hex: "#E8E8E8")
        return imageView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = false
        return indicator
    }()

    private let bottomBarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "video_menuBg"))
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let voiceButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "video_voice"), for: .normal)
        return button
    }()

    private let hangUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "video_off"), for: .normal)
        return button
    }()

    private let micButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "video_mic"), for: .normal)
        return button
    }()

}
