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
    static let postPublishCoinCost = 10

    private(set) var user: JC_UserModel?

    var isLoggedIn: Bool {
        user != nil && UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
    }

    private enum Keys {
        static let isLoggedIn = "jc_isLoggedIn"
        static let loginType = "jc_loginType"
        static let storedUser = "jc_storedUser"
        static let testUserProfile = "jc_testUserProfile"
        static let blockedUserIds = "jc_blockedUserIds"
    }

    private var blockedUserIds: Set<String> = []

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
        let appleUserIdentifier: String?
        let isProfileCompleted: Bool

        private enum CodingKeys: String, CodingKey {
            case userId, nickname, genderRaw, age, bio, friendCount, likeCount, coinCount
            case email, password, isBlock, followingUserIds, avatarPath
            case appleUserIdentifier, isProfileCompleted
        }

        init(
            user: JC_UserModel,
            avatarPath: String?,
            appleUserIdentifier: String? = nil,
            isProfileCompleted: Bool = true
        ) {
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
            self.appleUserIdentifier = appleUserIdentifier
            self.isProfileCompleted = isProfileCompleted
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(String.self, forKey: .userId)
            nickname = try container.decode(String.self, forKey: .nickname)
            genderRaw = try container.decode(String.self, forKey: .genderRaw)
            age = try container.decode(Int.self, forKey: .age)
            bio = try container.decode(String.self, forKey: .bio)
            friendCount = try container.decode(Int.self, forKey: .friendCount)
            likeCount = try container.decode(Int.self, forKey: .likeCount)
            coinCount = try container.decode(Int.self, forKey: .coinCount)
            email = try container.decode(String.self, forKey: .email)
            password = try container.decode(String.self, forKey: .password)
            isBlock = try container.decode(Bool.self, forKey: .isBlock)
            followingUserIds = try container.decode([String].self, forKey: .followingUserIds)
            avatarPath = try container.decodeIfPresent(String.self, forKey: .avatarPath)
            appleUserIdentifier = try container.decodeIfPresent(String.self, forKey: .appleUserIdentifier)
            isProfileCompleted = try container.decodeIfPresent(Bool.self, forKey: .isProfileCompleted) ?? true
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
                avatar: JC_CurrentUser.shared.loadAvatar(path: avatarPath, userId: userId),
                email: email,
                password: password,
                isBlock: isBlock,
                followingUserIds: followingUserIds
            )
        }
    }

    private init() {
        loadBlockedUserIds()
    }

    func isUserBlocked(userId: String) -> Bool {
        blockedUserIds.contains(userId)
    }

    var blockedUserIdsList: [String] {
        blockedUserIds.sorted()
    }

    func blockUser(userId: String) {
        guard !userId.isEmpty else { return }
        blockedUserIds.insert(userId)
        saveBlockedUserIds()
        NotificationCenter.default.post(name: .jcBlockedUsersDidChange, object: nil)
        NotificationCenter.default.post(name: .jcPostsDidChange, object: nil)
    }

    func unblockUser(userId: String) {
        guard blockedUserIds.remove(userId) != nil else { return }
        saveBlockedUserIds()
        NotificationCenter.default.post(name: .jcBlockedUsersDidChange, object: nil)
        NotificationCenter.default.post(name: .jcPostsDidChange, object: nil)
    }

    func isFollowing(userId: String) -> Bool {
        user?.isFollowing(userId: userId) ?? false
    }

    @discardableResult
    func toggleFollow(userId: String) -> Bool? {
        guard var model = user, model.userId != userId else { return nil }

        if let index = model.followingUserIds.firstIndex(of: userId) {
            model.followingUserIds.remove(at: index)
        } else {
            model.followingUserIds.append(userId)
        }

        user = model
        persistProfile(avatarPath: currentStoredAvatarPath())
        NotificationCenter.default.post(name: .jcUserProfileDidChange, object: nil)
        NotificationCenter.default.post(name: .jcPostsDidChange, object: nil)
        return model.isFollowing(userId: userId)
    }

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
            if let data = UserDefaults.standard.data(forKey: Keys.testUserProfile),
               let stored = try? JSONDecoder().decode(StoredUser.self, from: data) {
                user = userWithResolvedAvatar(stored.toUserModel(), avatarPath: stored.avatarPath)
            } else {
                user = JC_UserData.testUser
            }
        case .registered:
            guard let data = UserDefaults.standard.data(forKey: Keys.storedUser),
                  let stored = try? JSONDecoder().decode(StoredUser.self, from: data),
                  stored.isProfileCompleted else {
                clearSession()
                return
            }
            user = userWithResolvedAvatar(stored.toUserModel(), avatarPath: stored.avatarPath)
        case .apple:
            guard let data = UserDefaults.standard.data(forKey: Keys.storedUser),
                  let stored = try? JSONDecoder().decode(StoredUser.self, from: data),
                  stored.isProfileCompleted,
                  stored.appleUserIdentifier != nil else {
                clearSession()
                return
            }
            user = userWithResolvedAvatar(stored.toUserModel(), avatarPath: stored.avatarPath)
        }
    }

    @discardableResult
    func login(email: String, password: String) -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, !normalizedPassword.isEmpty else { return false }

        if normalizedEmail == Self.testEmail.lowercased(),
           normalizedPassword == Self.testPassword {
            applyLogin(
                user: JC_UserData.testUser,
                type: .test,
                avatarPath: nil,
                appleUserIdentifier: nil,
                isProfileCompleted: true
            )
            return true
        }

        if let stored = loadStoredUser(),
           stored.email.lowercased() == normalizedEmail,
           stored.password == normalizedPassword {
            user = userWithResolvedAvatar(stored.toUserModel(), avatarPath: stored.avatarPath)
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
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let userId = "user_reg_\(UUID().uuidString.prefix(8))"
        let avatarPath = saveAvatar(avatar, userId: userId)

        // 新注册账号：独立 JC_UserModel，不复用、不写入 testUser / testUserProfile
        var model = JC_UserModel(
            userId: userId,
            nickname: trimmedNickname.isEmpty ? "New User" : trimmedNickname,
            gender: .female,
            age: 18,
            bio: "",
            friendCount: 0,
            likeCount: 0,
            coinCount: 0,
            avatar: nil,
            email: normalizedEmail,
            password: password,
            isBlock: false,
            followingUserIds: []
        )
        model = userWithResolvedAvatar(model, avatarPath: avatarPath, fallback: avatar)

        applyLogin(
            user: model,
            type: .registered,
            avatarPath: avatarPath,
            appleUserIdentifier: nil,
            isProfileCompleted: true
        )
    }

    func processAppleSignIn(_ credential: JC_AppleSignInCredential) -> JC_AppleSignInOutcome {
        if let stored = loadStoredUser(),
           stored.appleUserIdentifier == credential.userIdentifier,
           stored.isProfileCompleted {
            let model = userWithResolvedAvatar(stored.toUserModel(), avatarPath: stored.avatarPath)
            applyLogin(
                user: model,
                type: .apple,
                avatarPath: stored.avatarPath,
                appleUserIdentifier: credential.userIdentifier,
                isProfileCompleted: true
            )
            return .completed
        }
        return .needsProfileSetup(credential)
    }

    func completeAppleProfile(
        credential: JC_AppleSignInCredential,
        nickname: String,
        avatar: UIImage?
    ) {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let userId = appleUserId(from: credential.userIdentifier)
        let avatarPath = saveAvatar(avatar, userId: userId)
        let normalizedEmail = credential.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        var model = JC_UserModel(
            userId: userId,
            nickname: trimmedNickname.isEmpty ? "Apple User" : trimmedNickname,
            gender: .female,
            age: 18,
            bio: "",
            friendCount: 0,
            likeCount: 0,
            coinCount: 0,
            avatar: nil,
            email: normalizedEmail,
            password: "",
            isBlock: false,
            followingUserIds: []
        )
        model = userWithResolvedAvatar(model, avatarPath: avatarPath, fallback: avatar)

        applyLogin(
            user: model,
            type: .apple,
            avatarPath: avatarPath,
            appleUserIdentifier: credential.userIdentifier,
            isProfileCompleted: true
        )
    }

    func logout() {
        clearSession()
    }

    func deleteAccount() {
        if let user {
            deleteAvatarFiles(userId: user.userId, path: currentStoredAvatarPath())
        }

        JC_PostStore.shared.clearAllLocalData()
        JC_ChatStore.shared.clearAllData()
        clearSession()

        NotificationCenter.default.post(name: .jcUserProfileDidChange, object: nil)
        NotificationCenter.default.post(name: .jcPostsDidChange, object: nil)
        NotificationCenter.default.post(name: .jcChatDidChange, object: nil)
        NotificationCenter.default.post(name: .jcBlockedUsersDidChange, object: nil)
    }

    var coinCount: Int {
        user?.coinCount ?? 0
    }

    var hasEnoughCoinsForPost: Bool {
        coinCount >= Self.postPublishCoinCost
    }

    @discardableResult
    func publishPost(content: String, media: JC_HomePostMedia) -> Bool {
        guard let user, user.coinCount >= Self.postPublishCoinCost else { return false }
        guard JC_PostStore.shared.addUserPost(content: content, media: media, author: user) else {
            return false
        }
        return spendCoins(Self.postPublishCoinCost)
    }

    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard var model = user, amount > 0, model.coinCount >= amount else { return false }
        model.coinCount -= amount
        user = model
        persistProfile(avatarPath: currentStoredAvatarPath())
        NotificationCenter.default.post(name: .jcUserProfileDidChange, object: nil)
        return true
    }

    @discardableResult
    func addCoins(_ amount: Int) -> Int? {
        guard var model = user, amount > 0 else { return nil }
        model.coinCount += amount
        user = model
        persistProfile(avatarPath: currentStoredAvatarPath())
        NotificationCenter.default.post(name: .jcUserProfileDidChange, object: nil)
        return model.coinCount
    }

    func updateProfile(nickname: String, bio: String, gender: JC_UserGender, avatar: UIImage?) {
        guard var model = user else { return }

        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNickname.isEmpty else { return }

        model.nickname = trimmedNickname
        model.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        model.gender = gender

        var avatarPath = currentStoredAvatarPath()
        if let avatar {
            if let savedPath = saveAvatar(avatar, userId: model.userId) {
                avatarPath = savedPath
                model.avatar = avatar
            } else if let path = avatarPath, let cached = loadAvatar(path: path, userId: model.userId) {
                model.avatar = cached
            }
        } else if model.avatar == nil,
                  let path = avatarPath,
                  let cached = loadAvatar(path: path, userId: model.userId) {
            model.avatar = cached
        }

        let resolvedPath = resolvedStoredAvatarPath(userId: model.userId, explicitPath: avatarPath)
        user = userWithResolvedAvatar(model, avatarPath: resolvedPath)
        persistProfile(avatarPath: resolvedPath)
        NotificationCenter.default.post(name: .jcUserProfileDidChange, object: nil)
    }

    /// 从磁盘重新加载当前用户头像（内存中 avatar 丢失时可在页面展示前调用）
    func refreshCurrentUserAvatar() {
        guard var model = user else { return }
        let path = currentStoredAvatarPath()
        if let image = loadAvatar(path: path, userId: model.userId) {
            model.avatar = image
            user = model
        }
    }

    func showMainInterface(in window: UIWindow?) {
        window?.rootViewController = JC_TabbarVC()
    }

    func showWelcomeInterface(in window: UIWindow?) {
        let nav = UINavigationController(rootViewController: JC_WelcomeVC())
        nav.navigationBar.isHidden = true
        window?.rootViewController = nav
    }

    private func applyLogin(
        user: JC_UserModel,
        type: LoginType,
        avatarPath: String?,
        appleUserIdentifier: String? = nil,
        isProfileCompleted: Bool = true
    ) {
        let resolvedPath = resolvedStoredAvatarPath(userId: user.userId, explicitPath: avatarPath)
        self.user = userWithResolvedAvatar(user, avatarPath: resolvedPath)
        UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
        UserDefaults.standard.set(type.rawValue, forKey: Keys.loginType)

        switch type {
        case .test:
            UserDefaults.standard.removeObject(forKey: Keys.storedUser)
            persistStoredUser(
                self.user!,
                avatarPath: resolvedPath,
                key: Keys.testUserProfile,
                appleUserIdentifier: nil,
                isProfileCompleted: true
            )
        case .registered:
            UserDefaults.standard.removeObject(forKey: Keys.testUserProfile)
            persistStoredUser(
                self.user!,
                avatarPath: resolvedPath,
                key: Keys.storedUser,
                appleUserIdentifier: nil,
                isProfileCompleted: true
            )
        case .apple:
            UserDefaults.standard.removeObject(forKey: Keys.testUserProfile)
            persistStoredUser(
                self.user!,
                avatarPath: resolvedPath,
                key: Keys.storedUser,
                appleUserIdentifier: appleUserIdentifier,
                isProfileCompleted: isProfileCompleted
            )
        }

        NotificationCenter.default.post(name: .jcUserProfileDidChange, object: nil)
    }

    private func persistStoredUser(
        _ user: JC_UserModel,
        avatarPath: String?,
        key: String,
        appleUserIdentifier: String? = nil,
        isProfileCompleted: Bool = true
    ) {
        let stored = StoredUser(
            user: user,
            avatarPath: avatarPath,
            appleUserIdentifier: appleUserIdentifier,
            isProfileCompleted: isProfileCompleted
        )
        guard let data = try? JSONEncoder().encode(stored) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func appleUserId(from appleUserIdentifier: String) -> String {
        let sanitized = appleUserIdentifier
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return "user_apple_\(sanitized)"
    }

    private func clearSession() {
        user = nil
        blockedUserIds.removeAll()
        UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Keys.loginType)
        UserDefaults.standard.removeObject(forKey: Keys.storedUser)
        UserDefaults.standard.removeObject(forKey: Keys.testUserProfile)
        UserDefaults.standard.removeObject(forKey: Keys.blockedUserIds)
    }

    private func loadBlockedUserIds() {
        if let ids = UserDefaults.standard.array(forKey: Keys.blockedUserIds) as? [String] {
            blockedUserIds = Set(ids)
        }
    }

    private func saveBlockedUserIds() {
        UserDefaults.standard.set(Array(blockedUserIds), forKey: Keys.blockedUserIds)
    }

    private func persistProfile(avatarPath: String?) {
        guard let user else { return }
        guard let typeRaw = UserDefaults.standard.string(forKey: Keys.loginType),
              let type = LoginType(rawValue: typeRaw) else { return }

        switch type {
        case .test:
            persistStoredUser(user, avatarPath: avatarPath, key: Keys.testUserProfile)
        case .registered, .apple:
            persistStoredUser(user, avatarPath: avatarPath, key: Keys.storedUser)
        }
    }

    private func currentStoredAvatarPath() -> String? {
        if let stored = loadStoredUser() {
            return resolvedStoredAvatarPath(userId: stored.userId, explicitPath: stored.avatarPath)
        }
        if let data = UserDefaults.standard.data(forKey: Keys.testUserProfile),
           let stored = try? JSONDecoder().decode(StoredUser.self, from: data) {
            return resolvedStoredAvatarPath(userId: stored.userId, explicitPath: stored.avatarPath)
        }
        return nil
    }

    private func userWithResolvedAvatar(
        _ model: JC_UserModel,
        avatarPath: String?,
        fallback: UIImage? = nil
    ) -> JC_UserModel {
        var updated = model
        if let image = loadAvatar(path: avatarPath, userId: model.userId) {
            updated.avatar = image
        } else if updated.avatar == nil {
            updated.avatar = fallback
        }
        return updated
    }

    private func resolvedStoredAvatarPath(userId: String, explicitPath: String?) -> String? {
        if FileManager.default.fileExists(atPath: avatarFileURL(for: userId).path) {
            return avatarFileName(for: userId)
        }
        return explicitPath
    }

    private func avatarFileName(for userId: String) -> String {
        "\(userId).png"
    }

    private func avatarFileURL(for userId: String) -> URL {
        avatarsDirectoryURL().appendingPathComponent(avatarFileName(for: userId))
    }

    private func loadStoredUser() -> StoredUser? {
        guard let data = UserDefaults.standard.data(forKey: Keys.storedUser) else { return nil }
        return try? JSONDecoder().decode(StoredUser.self, from: data)
    }

    private func saveAvatar(_ image: UIImage?, userId: String) -> String? {
        guard let image, let data = normalizedAvatarData(from: image) else { return nil }

        let directory = avatarsDirectoryURL()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = avatarFileURL(for: userId)
        do {
            try data.write(to: fileURL, options: .atomic)
            return avatarFileName(for: userId)
        } catch {
            return nil
        }
    }

    private func normalizedAvatarData(from image: UIImage) -> Data? {
        let maxSide: CGFloat = 800
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let scale = min(1, maxSide / max(size.width, size.height))
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let rendered = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return rendered.jpegData(compressionQuality: 0.88) ?? rendered.pngData()
    }

    fileprivate func loadAvatar(path: String?, userId: String) -> UIImage? {
        var candidateURLs: [URL] = [avatarFileURL(for: userId)]

        if let path, !path.isEmpty {
            if path.hasPrefix("/") {
                candidateURLs.insert(URL(fileURLWithPath: path), at: 0)
            } else {
                candidateURLs.insert(avatarsDirectoryURL().appendingPathComponent(path), at: 0)
            }
        }

        for url in candidateURLs {
            guard FileManager.default.fileExists(atPath: url.path),
                  let image = UIImage(contentsOfFile: url.path) else {
                continue
            }
            return image
        }

        if userId == JC_UserData.testUser.userId {
            return JC_UserData.testUser.avatar
        }
        return nil
    }

    private func avatarsDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatars", isDirectory: true)
    }

    private func deleteAvatarFiles(userId: String, path: String?) {
        if let path, path.hasPrefix("/"), FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        let fileURL = avatarFileURL(for: userId)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

}
