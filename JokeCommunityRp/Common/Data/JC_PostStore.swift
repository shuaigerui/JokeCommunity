//
//  JC_PostStore.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import Foundation
import UIKit

extension Notification.Name {
    static let jcPostsDidChange = Notification.Name("jcPostsDidChange")
    static let jcUserProfileDidChange = Notification.Name("jcUserProfileDidChange")
    static let jcBlockedUsersDidChange = Notification.Name("jcBlockedUsersDidChange")
}

struct JC_LikeToggleResult {
    let isLiked: Bool
    let likeCount: String
}

struct JC_DislikeToggleResult {
    let isDisliked: Bool
    let dislikeCount: String
}

final class JC_PostStore {

    static let shared = JC_PostStore()

    private enum Keys {
        static let deletedPostIds = "jc_deletedPostIds"
        static let reportedPostIds = "jc_reportedPostIds"
        static let userPosts = "jc_userPosts"
        static let likedPostIds = "jc_likedPostIds"
        static let likeCountOverrides = "jc_likeCountOverrides"
        static let dislikedPostIds = "jc_dislikedPostIds"
        static let dislikeCountOverrides = "jc_dislikeCountOverrides"
        static let postComments = "jc_postComments"
        static let hiddenCommentIds = "jc_hiddenCommentIds"
    }

    private struct StoredPostComment: Codable {
        let commentId: String
        let userId: String
        let userName: String
        let content: String

        init(commentId: String, userId: String, userName: String, content: String) {
            self.commentId = commentId
            self.userId = userId
            self.userName = userName
            self.content = content
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(String.self, forKey: .userId)
            userName = try container.decode(String.self, forKey: .userName)
            content = try container.decode(String.self, forKey: .content)
            commentId = try container.decodeIfPresent(String.self, forKey: .commentId) ?? UUID().uuidString
        }

        private enum CodingKeys: String, CodingKey {
            case commentId, userId, userName, content
        }
    }

    private struct StoredPostRecord: Codable {
        let postId: String
        let authorUserId: String
        let content: String
        let likeCount: String
        let dislikeCount: String
        let mediaKind: String
        let mediaFileNames: [String]

        init(
            postId: String,
            authorUserId: String,
            content: String,
            likeCount: String,
            dislikeCount: String = "0",
            mediaKind: String,
            mediaFileNames: [String]
        ) {
            self.postId = postId
            self.authorUserId = authorUserId
            self.content = content
            self.likeCount = likeCount
            self.dislikeCount = dislikeCount
            self.mediaKind = mediaKind
            self.mediaFileNames = mediaFileNames
        }

        private enum CodingKeys: String, CodingKey {
            case postId, authorUserId, content, likeCount, dislikeCount, mediaKind, mediaFileNames
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            postId = try container.decode(String.self, forKey: .postId)
            authorUserId = try container.decode(String.self, forKey: .authorUserId)
            content = try container.decode(String.self, forKey: .content)
            likeCount = try container.decode(String.self, forKey: .likeCount)
            dislikeCount = try container.decodeIfPresent(String.self, forKey: .dislikeCount) ?? "0"
            mediaKind = try container.decode(String.self, forKey: .mediaKind)
            mediaFileNames = try container.decode([String].self, forKey: .mediaFileNames)
        }
    }

    private var basePosts: [JC_PostModel] = []
    private var userPostRecords: [StoredPostRecord] = []
    private var deletedPostIds: Set<String> = []
    private var reportedPostIds: Set<String> = []
    private var likedPostIds: Set<String> = []
    private var likeCountOverrides: [String: String] = [:]
    private var dislikedPostIds: Set<String> = []
    private var dislikeCountOverrides: [String: String] = [:]
    private var userComments: [String: [StoredPostComment]] = [:]
    private var hiddenCommentIds: Set<String> = []

    private init() {
        reloadBootstrapPosts()
        loadPersistedState()
        mergePersistedUserPosts()
        applyPersistedEngagementState()
    }

    func post(postId: String) -> JC_PostModel? {
        basePosts.first { $0.postId == postId }
    }

    func comments(for postId: String) -> [JC_PostComment] {
        let seed = (post(postId: postId)?.comments ?? []).filter { !hiddenCommentIds.contains($0.commentId) }
        let extra = (userComments[postId] ?? [])
            .map { makeComment(from: $0) }
            .filter { !hiddenCommentIds.contains($0.commentId) }
        return seed + extra
    }

    @discardableResult
    func addComment(postId: String, userId: String, userName: String, content: String) -> JC_PostComment? {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !postId.isEmpty, post(postId: postId) != nil else { return nil }

        let stored = StoredPostComment(
            commentId: UUID().uuidString,
            userId: userId,
            userName: userName,
            content: trimmed
        )
        var list = userComments[postId] ?? []
        list.append(stored)
        userComments[postId] = list
        saveUserComments()
        notifyPostsDidChange()
        return makeComment(from: stored)
    }

    @discardableResult
    func deleteComment(postId: String, commentId: String) -> Bool {
        guard var list = userComments[postId],
              let index = list.firstIndex(where: { $0.commentId == commentId }) else {
            return false
        }
        list.remove(at: index)
        userComments[postId] = list.isEmpty ? nil : list
        if list.isEmpty {
            userComments.removeValue(forKey: postId)
        }
        saveUserComments()
        notifyPostsDidChange()
        return true
    }

    func reportComment(commentId: String) {
        guard !commentId.isEmpty else { return }
        hiddenCommentIds.insert(commentId)
        saveHiddenComments()
        notifyPostsDidChange()
    }

    private func makeComment(from stored: StoredPostComment) -> JC_PostComment {
        let avatar = JC_UserData.resolvedUser(userId: stored.userId)?.avatar
        return JC_PostComment(
            commentId: stored.commentId,
            userId: stored.userId,
            userName: stored.userName,
            content: stored.content,
            avatar: avatar,
            isUserAdded: true
        )
    }

    func isLiked(postId: String) -> Bool {
        likedPostIds.contains(postId)
    }

    @discardableResult
    func toggleLike(postId: String) -> JC_LikeToggleResult? {
        guard let index = basePosts.firstIndex(where: { $0.postId == postId }) else { return nil }

        var post = basePosts[index]
        let wasLiked = likedPostIds.contains(postId)
        let parsed = Self.parseLikeDisplay(post.likeCount)
        var value = parsed.value

        if wasLiked {
            likedPostIds.remove(postId)
            value = max(0, value - 1)
        } else {
            likedPostIds.insert(postId)
            value += 1
        }

        let newCountText = Self.formatLikeDisplay(value, usesW: parsed.usesW)
        post.likeCount = newCountText
        basePosts[index] = post
        likeCountOverrides[postId] = newCountText
        syncUserPostRecordLikeCount(postId: postId, likeCount: newCountText)
        saveLikeState()

        let result = JC_LikeToggleResult(isLiked: !wasLiked, likeCount: newCountText)
        notifyPostsDidChange()
        return result
    }

    func isDisliked(postId: String) -> Bool {
        dislikedPostIds.contains(postId)
    }

    @discardableResult
    func toggleDislike(postId: String) -> JC_DislikeToggleResult? {
        guard let index = basePosts.firstIndex(where: { $0.postId == postId }) else { return nil }

        var post = basePosts[index]
        let wasDisliked = dislikedPostIds.contains(postId)
        let parsed = Self.parseCountDisplay(post.dislikeCount)
        var value = parsed.value

        if wasDisliked {
            dislikedPostIds.remove(postId)
            value = max(0, value - 1)
        } else {
            dislikedPostIds.insert(postId)
            value += 1
        }

        let newCountText = Self.formatCountDisplay(value, usesW: parsed.usesW)
        post.dislikeCount = newCountText
        post.isDisliked = !wasDisliked
        basePosts[index] = post
        dislikeCountOverrides[postId] = newCountText
        syncUserPostRecordEngagement(postId: postId, likeCount: post.likeCount, dislikeCount: newCountText)
        saveEngagementState()

        let result = JC_DislikeToggleResult(isDisliked: !wasDisliked, dislikeCount: newCountText)
        notifyPostsDidChange()
        return result
    }

    private static func parseLikeDisplay(_ text: String) -> (value: Int, usesW: Bool) {
        parseCountDisplay(text)
    }

    private static func parseCountDisplay(_ text: String) -> (value: Int, usesW: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if trimmed.hasSuffix("W") {
            return (Int(trimmed.dropLast()) ?? 0, true)
        }
        return (Int(trimmed) ?? 0, false)
    }

    private static func formatLikeDisplay(_ value: Int, usesW: Bool) -> String {
        formatCountDisplay(value, usesW: usesW)
    }

    private static func formatCountDisplay(_ value: Int, usesW: Bool) -> String {
        usesW ? "\(max(0, value))W" : "\(max(0, value))"
    }

    var visiblePosts: [JC_PostModel] {
        basePosts
            .filter { !deletedPostIds.contains($0.postId) }
            .filter { !JC_CurrentUser.shared.isUserBlocked(userId: $0.author.userId) }
            .map { post in
                var updated = post
                if reportedPostIds.contains(post.postId) {
                    updated.isReport = true
                }
                return updated
            }
            .filter { !$0.isReport }
    }

    @discardableResult
    func addUserPost(content: String, media: JC_HomePostMedia, author: JC_UserModel) -> Bool {
        let postId = "post_user_\(UUID().uuidString.prefix(12))"
        guard let (mediaKind, fileNames, postMedia) = persistMedia(media, postId: postId) else {
            return false
        }

        let record = StoredPostRecord(
            postId: postId,
            authorUserId: author.userId,
            content: content,
            likeCount: "0",
            dislikeCount: "0",
            mediaKind: mediaKind,
            mediaFileNames: fileNames
        )
        userPostRecords.insert(record, at: 0)
        saveUserPostRecords()

        let post = JC_PostModel(
            postId: postId,
            author: author,
            content: content,
            media: postMedia,
            likeCount: "0",
            dislikeCount: "0",
            isDisliked: false,
            relationText: "",
            isReport: false,
            comments: []
        )
        basePosts.insert(post, at: 0)
        notifyPostsDidChange()
        return true
    }

    func deletePost(postId: String) {
        deletedPostIds.insert(postId)
        userComments.removeValue(forKey: postId)
        saveUserComments()
        if userPostRecords.contains(where: { $0.postId == postId }) {
            removePersistedUserPost(postId: postId)
        }
        savePersistedState()
        notifyPostsDidChange()
    }

    func reportPost(postId: String) {
        reportedPostIds.insert(postId)
        savePersistedState()
        notifyPostsDidChange()
    }

    private func reloadBootstrapPosts() {
        basePosts = JC_UserData.makeBootstrapPosts()
    }

    private func mergePersistedUserPosts() {
        let posts = userPostRecords.compactMap { makePostModel(from: $0) }
        basePosts = posts + basePosts
    }

    private func applyPersistedEngagementState() {
        for index in basePosts.indices {
            let postId = basePosts[index].postId
            if let count = likeCountOverrides[postId] {
                basePosts[index].likeCount = count
            }
            if let count = dislikeCountOverrides[postId] {
                basePosts[index].dislikeCount = count
            }
            basePosts[index].isDisliked = dislikedPostIds.contains(postId)
        }
    }

    private func syncUserPostRecordEngagement(postId: String, likeCount: String, dislikeCount: String) {
        guard let index = userPostRecords.firstIndex(where: { $0.postId == postId }) else { return }
        let old = userPostRecords[index]
        userPostRecords[index] = StoredPostRecord(
            postId: old.postId,
            authorUserId: old.authorUserId,
            content: old.content,
            likeCount: likeCount,
            dislikeCount: dislikeCount,
            mediaKind: old.mediaKind,
            mediaFileNames: old.mediaFileNames
        )
        saveUserPostRecords()
    }

    private func syncUserPostRecordLikeCount(postId: String, likeCount: String) {
        guard let index = userPostRecords.firstIndex(where: { $0.postId == postId }) else { return }
        let old = userPostRecords[index]
        syncUserPostRecordEngagement(
            postId: postId,
            likeCount: likeCount,
            dislikeCount: old.dislikeCount
        )
    }

    private func makePostModel(from record: StoredPostRecord) -> JC_PostModel? {
        guard let media = loadMedia(for: record) else { return nil }
        let author = JC_UserData.resolvedUser(userId: record.authorUserId)
            ?? JC_UserData.testUser
        var post = JC_PostModel(
            postId: record.postId,
            author: author,
            content: record.content,
            media: media,
            likeCount: record.likeCount,
            dislikeCount: record.dislikeCount,
            isDisliked: dislikedPostIds.contains(record.postId),
            relationText: "",
            isReport: false,
            comments: []
        )
        if let count = likeCountOverrides[record.postId] {
            post.likeCount = count
        }
        if let count = dislikeCountOverrides[record.postId] {
            post.dislikeCount = count
        }
        post.isDisliked = dislikedPostIds.contains(record.postId)
        return post
    }

    private func loadMedia(for record: StoredPostRecord) -> JC_PostMedia? {
        let directory = postDirectory(for: record.postId)
        switch record.mediaKind {
        case "video":
            guard let name = record.mediaFileNames.first else { return nil }
            let url = directory.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            return .video(url)
        case "images":
            var images: [UIImage] = []
            for name in record.mediaFileNames {
                let path = directory.appendingPathComponent(name).path
                if let image = UIImage(contentsOfFile: path) {
                    images.append(image)
                }
            }
            return JC_PostMedia(images: images)
        default:
            return nil
        }
    }

    private func persistMedia(
        _ media: JC_HomePostMedia,
        postId: String
    ) -> (kind: String, fileNames: [String], postMedia: JC_PostMedia)? {
        let directory = postDirectory(for: postId)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        switch media {
        case .video(let sourceURL):
            let fileName = "video.mp4"
            let destination = directory.appendingPathComponent(fileName)
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: sourceURL, to: destination)
                return ("video", [fileName], .video(destination))
            } catch {
                return nil
            }
        case .images(let images):
            guard images.count == 2 else { return nil }
            var fileNames: [String] = []
            var loaded: [UIImage] = []
            for (index, image) in images.enumerated() {
                let fileName = "image_\(index).jpg"
                let fileURL = directory.appendingPathComponent(fileName)
                guard let data = image.jpegData(compressionQuality: 0.9) ?? image.pngData() else {
                    return nil
                }
                do {
                    try data.write(to: fileURL, options: .atomic)
                    fileNames.append(fileName)
                    loaded.append(image)
                } catch {
                    return nil
                }
            }
            guard let postMedia = JC_PostMedia(images: loaded) else { return nil }
            return ("images", fileNames, postMedia)
        case .none:
            return nil
        }
    }

    private func postDirectory(for postId: String) -> URL {
        userPostsDirectoryURL().appendingPathComponent(postId, isDirectory: true)
    }

    private func userPostsDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("userPosts", isDirectory: true)
    }

    private func removePersistedUserPost(postId: String) {
        userPostRecords.removeAll { $0.postId == postId }
        saveUserPostRecords()
        let directory = postDirectory(for: postId)
        try? FileManager.default.removeItem(at: directory)
        basePosts.removeAll { $0.postId == postId }
    }

    private func loadPersistedState() {
        if let deleted = UserDefaults.standard.array(forKey: Keys.deletedPostIds) as? [String] {
            deletedPostIds = Set(deleted)
        }
        if let reported = UserDefaults.standard.array(forKey: Keys.reportedPostIds) as? [String] {
            reportedPostIds = Set(reported)
        }
        if let data = UserDefaults.standard.data(forKey: Keys.userPosts),
           let records = try? JSONDecoder().decode([StoredPostRecord].self, from: data) {
            userPostRecords = records
        }
        if let liked = UserDefaults.standard.array(forKey: Keys.likedPostIds) as? [String] {
            likedPostIds = Set(liked)
        }
        if let data = UserDefaults.standard.data(forKey: Keys.likeCountOverrides),
           let overrides = try? JSONDecoder().decode([String: String].self, from: data) {
            likeCountOverrides = overrides
        }
        if let disliked = UserDefaults.standard.array(forKey: Keys.dislikedPostIds) as? [String] {
            dislikedPostIds = Set(disliked)
        }
        if let data = UserDefaults.standard.data(forKey: Keys.dislikeCountOverrides),
           let overrides = try? JSONDecoder().decode([String: String].self, from: data) {
            dislikeCountOverrides = overrides
        }
        if let data = UserDefaults.standard.data(forKey: Keys.postComments),
           let comments = try? JSONDecoder().decode([String: [StoredPostComment]].self, from: data) {
            userComments = comments
        }
        if let hidden = UserDefaults.standard.array(forKey: Keys.hiddenCommentIds) as? [String] {
            hiddenCommentIds = Set(hidden)
        }
    }

    private func savePersistedState() {
        UserDefaults.standard.set(Array(deletedPostIds), forKey: Keys.deletedPostIds)
        UserDefaults.standard.set(Array(reportedPostIds), forKey: Keys.reportedPostIds)
    }

    private func saveLikeState() {
        saveEngagementState()
    }

    private func saveEngagementState() {
        UserDefaults.standard.set(Array(likedPostIds), forKey: Keys.likedPostIds)
        if let data = try? JSONEncoder().encode(likeCountOverrides) {
            UserDefaults.standard.set(data, forKey: Keys.likeCountOverrides)
        }
        UserDefaults.standard.set(Array(dislikedPostIds), forKey: Keys.dislikedPostIds)
        if let data = try? JSONEncoder().encode(dislikeCountOverrides) {
            UserDefaults.standard.set(data, forKey: Keys.dislikeCountOverrides)
        }
    }

    private func saveUserPostRecords() {
        if let data = try? JSONEncoder().encode(userPostRecords) {
            UserDefaults.standard.set(data, forKey: Keys.userPosts)
        }
    }

    private func saveUserComments() {
        if let data = try? JSONEncoder().encode(userComments) {
            UserDefaults.standard.set(data, forKey: Keys.postComments)
        }
    }

    private func saveHiddenComments() {
        UserDefaults.standard.set(Array(hiddenCommentIds), forKey: Keys.hiddenCommentIds)
    }

    private func notifyPostsDidChange() {
        NotificationCenter.default.post(name: .jcPostsDidChange, object: nil)
    }

}
