//
//  JC_MediaPermission.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import AVFoundation
import UIKit

enum JC_MediaPermission {

    static var isCameraAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    static var isMicrophoneAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    static var isFullyAuthorized: Bool {
        isCameraAuthorized && isMicrophoneAuthorized
    }

    static func ensureVideoCallPermissions(
        on viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        if cameraStatus == .authorized, micStatus == .authorized {
            completion(true)
            return
        }

        if cameraStatus == .denied || cameraStatus == .restricted
            || micStatus == .denied || micStatus == .restricted {
            presentSettingsAlert(on: viewController)
            completion(false)
            return
        }

        requestAccess { granted in
            DispatchQueue.main.async {
                if granted {
                    completion(true)
                } else {
                    presentSettingsAlert(on: viewController)
                    completion(false)
                }
            }
        }
    }

    private static func requestAccess(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var cameraGranted = false
        var micGranted = false

        group.enter()
        AVCaptureDevice.requestAccess(for: .video) { granted in
            cameraGranted = granted
            group.leave()
        }

        group.enter()
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            micGranted = granted
            group.leave()
        }

        group.notify(queue: .main) {
            completion(cameraGranted && micGranted)
        }
    }

    private static func presentSettingsAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Camera & Microphone Access",
            message: "Video calls need camera and microphone access. Please enable them in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        viewController.present(alert, animated: true)
    }
}
