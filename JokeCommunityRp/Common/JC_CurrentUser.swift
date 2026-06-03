//
//  JC_CurrentUser.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit

final class JC_CurrentUser {

    static let shared = JC_CurrentUser()

    static let testEmail = "test@gmail.com"
    static let testPassword = "123456"

    private(set) var user: JC_UserModel?

    var isLoggedIn: Bool {
        user != nil && UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
    }

    private enum Keys {
        static let isLoggedIn = "jc_isLoggedIn"
        static let loginType = "jc_loginType"
        static let storedUser = "jc_storedUser"
    }

    private enum LoginType: String {
        case test
        case registered
        case apple
    }

    private struct StoredUser: Codable {
        let userId: String
        let nickname: String
        let genderRaw: String
        let age: Int
        let bio: String
        let friendCount: Int
        let likeCount: Int
        let coinCount: Int
        let email: String
        let password: String
        let isBlock: Bool
        let followingUserIds: [String]
        let avatarPath: String?

        init(user: JC_UserModel, avatarPath: String?) {
            userId = user.userId
            nickname = user.nickname
            genderRaw = user.gender == .male ? "male" : "female"
            age = user.age
            bio = user.bio
            friendCount = user.friendCount
            likeCount = user.likeCount
            coinCount = user.coinCount
            email = user.email
            password = user.password
            isBlock = user.isBlock
            followingUserIds = user.followingUserIds
            self.avatarPath = avatarPath
        }

        func toUserModel() -> JC_UserModel {
            JC_UserModel(
                userId: userId,
                nickname: nickname,
                gender: genderRaw == "male" ? .male : .female,
                age: age,
                bio: bio,
                friendCount: friendCount,
                likeCount: likeCount,
                coinCount: coinCount,
                avatar: JC_CurrentUser.shared.loadAvatar(path: avatarPath),
                email: email,
                password: password,
                isBlock: isBlock,
                followingUserIds: followingUserIds
            )
        }
    }

    private init() {}

    func restoreSession() {
        guard UserDefaults.standard.bool(forKey: Keys.isLoggedIn) else {
            user = nil
            return
        }

        guard let typeRaw = UserDefaults.standard.string(forKey: Keys.loginType),
              let type = LoginType(rawValue: typeRaw) else {
            clearSession()
            return
        }

        switch type {
        case .test:
            user = JC_UserData.testUser
        case .registered, .apple:
            guard let data = UserDefaults.standard.data(forKey: Keys.storedUser),
                  let stored = try? JSONDecoder().decode(StoredUser.self, from: data) else {
                clearSession()
                return
            }
            user = stored.toUserModel()
        }
    }

    @discardableResult
    func login(email: String, password: String) -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, !normalizedPassword.isEmpty else { return false }

        if normalizedEmail == Self.testEmail.lowercased(),
           normalizedPassword == Self.testPassword {
            applyLogin(user: JC_UserData.testUser, type: .test, avatarPath: nil)
            return true
        }

        if let stored = loadStoredUser(),
           stored.email.lowercased() == normalizedEmail,
           stored.password == normalizedPassword {
            user = stored.toUserModel()
            UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
            UserDefaults.standard.set(LoginType.registered.rawValue, forKey: Keys.loginType)
            return true
        }

        return false
    }

    func loginWithRegistration(
        email: String,
        password: String,
        nickname: String,
        avatar: UIImage?
    ) {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let userId = "user_reg_\(UUID().uuidString.prefix(8))"
        let avatarPath = saveAvatar(avatar, userId: userId)

        let model = JC_UserModel(
            userId: userId,
            nickname: trimmedNickname.isEmpty ? "New User" : trimmedNickname,
            gender: .female,
            age: 18,
            bio: "",
            friendCount: 0,
            likeCount: 0,
            coinCount: 0,
            avatar: avatar,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            isBlock: false,
            followingUserIds: []
        )

        applyLogin(user: model, type: .registered, avatarPath: avatarPath)
    }

    func loginWithApple() {
        let userId = "user_apple_\(UUID().uuidString.prefix(8))"
        let model = JC_UserModel(
            userId: userId,
            nickname: "Apple User",
            gender: .female,
            age: 18,
            bio: "",
            friendCount: 0,
            likeCount: 0,
            coinCount: 0,
            avatar: nil,
            email: "",
            password: "",
            isBlock: false,
            followingUserIds: []
        )
        applyLogin(user: model, type: .apple, avatarPath: nil)
    }

    func logout() {
        clearSession()
    }

    func showMainInterface(in window: UIWindow?) {
        window?.rootViewController = JC_TabbarVC()
    }

    func showWelcomeInterface(in window: UIWindow?) {
        let nav = UINavigationController(rootViewController: JC_WelcomeVC())
        nav.navigationBar.isHidden = true
        window?.rootViewController = nav
    }

    private func applyLogin(user: JC_UserModel, type: LoginType, avatarPath: String?) {
        self.user = user
        UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
        UserDefaults.standard.set(type.rawValue, forKey: Keys.loginType)

        if type == .test {
            UserDefaults.standard.removeObject(forKey: Keys.storedUser)
        } else {
            let stored = StoredUser(user: user, avatarPath: avatarPath)
            if let data = try? JSONEncoder().encode(stored) {
                UserDefaults.standard.set(data, forKey: Keys.storedUser)
            }
        }
    }

    private func clearSession() {
        user = nil
        UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Keys.loginType)
        UserDefaults.standard.removeObject(forKey: Keys.storedUser)
    }

    private func loadStoredUser() -> StoredUser? {
        guard let data = UserDefaults.standard.data(forKey: Keys.storedUser) else { return nil }
        return try? JSONDecoder().decode(StoredUser.self, from: data)
    }

    private func saveAvatar(_ image: UIImage?, userId: String) -> String? {
        guard let image, let data = image.pngData() else { return nil }
        let directory = avatarsDirectoryURL()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = directory.appendingPathComponent("\(userId).png")
        try? data.write(to: fileURL)
        return fileURL.path
    }

    fileprivate func loadAvatar(path: String?) -> UIImage? {
        guard let path else { return nil }
        return UIImage(contentsOfFile: path)
    }

    private func avatarsDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatars", isDirectory: true)
    }

}
