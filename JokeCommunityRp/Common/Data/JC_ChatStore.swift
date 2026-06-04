//
//  JC_ChatStore.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit

extension Notification.Name {
    static let jcChatDidChange = Notification.Name("jcChatDidChange")
}

struct JC_StoredChatMessage: Codable, Equatable {
    let messageId: String
    let peerUserId: String
    let text: String
    let isOutgoing: Bool
    let createdAt: TimeInterval
}

final class JC_ChatStore {

    static let shared = JC_ChatStore()

    private enum Keys {
        static let messages = "jc_chatMessages"
    }

    private var messages: [JC_StoredChatMessage] = []

    private init() {
        load()
    }

    func messages(for peerUserId: String) -> [JC_StoredChatMessage] {
        messages
            .filter { $0.peerUserId == peerUserId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func roomMessages(for peerUserId: String) -> [JC_ChatRoomMessage] {
        let peer = JC_UserData.resolvedUser(userId: peerUserId)
        let currentUser = JC_CurrentUser.shared.user ?? JC_UserModel.current
        return messages(for: peerUserId).map { stored in
            JC_ChatRoomMessage(
                text: stored.text,
                isOutgoing: stored.isOutgoing,
                avatar: stored.isOutgoing ? currentUser.avatar : peer?.avatar
            )
        }
    }

    @discardableResult
    func sendMessage(peerUserId: String, text: String) -> JC_StoredChatMessage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !peerUserId.isEmpty else { return nil }

        let message = JC_StoredChatMessage(
            messageId: UUID().uuidString,
            peerUserId: peerUserId,
            text: trimmed,
            isOutgoing: true,
            createdAt: Date().timeIntervalSince1970
        )
        messages.append(message)
        save()
        notifyChatDidChange()
        return message
    }

    func deleteMessages(peerUserId: String) {
        guard !peerUserId.isEmpty else { return }
        let hadMessages = messages.contains { $0.peerUserId == peerUserId }
        messages.removeAll { $0.peerUserId == peerUserId }
        guard hadMessages else { return }
        save()
        notifyChatDidChange()
    }

    func clearAllData() {
        messages.removeAll()
        UserDefaults.standard.removeObject(forKey: Keys.messages)
        notifyChatDidChange()
    }

    func conversationListItems() -> [JC_ChatMessage] {
        let grouped = Dictionary(grouping: messages, by: \.peerUserId)
        let summaries: [(peerUserId: String, preview: String, updatedAt: TimeInterval)] = grouped.compactMap { peerUserId, list in
            guard let latest = list.max(by: { $0.createdAt < $1.createdAt }) else { return nil }
            return (peerUserId, latest.text, latest.createdAt)
        }
        .sorted { $0.updatedAt > $1.updatedAt }

        return summaries.map { item in
            let user = JC_UserData.resolvedUser(userId: item.peerUserId)
            return JC_ChatMessage(
                peerUserId: item.peerUserId,
                userName: (user?.nickname ?? item.peerUserId).uppercased(),
                preview: item.preview,
                avatar: user?.avatar
            )
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Keys.messages),
              let decoded = try? JSONDecoder().decode([JC_StoredChatMessage].self, from: data) else {
            messages = []
            return
        }
        messages = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: Keys.messages)
    }

    private func notifyChatDidChange() {
        NotificationCenter.default.post(name: .jcChatDidChange, object: nil)
    }
}
