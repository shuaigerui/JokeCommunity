//
//  JC_UserData.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit

enum JC_UserData {

    static let testUser = JC_UserModel(
        userId: "user_test",
        nickname: "Angela",
        gender: .female,
        age: 20,
        bio: "This is my first time sharing a joke, I .......",
        friendCount: 950,
        likeCount: 1000,
        coinCount: 120,
        avatar: bundleImage(name: "avatar_01", directory: "Avatar"),
        email: "test@gmail.com",
        password: "123456",
        isBlock: false,
        followingUserIds: ["user_002", "user_003"]
    )

    static let localUsers: [JC_UserModel] = [
        JC_UserModel(
            userId: "user_002",
            nickname: "Mason",
            gender: .male,
            age: 24,
            bio: "Stand-up comedy is my weekend therapy.",
            friendCount: 320,
            likeCount: 860,
            coinCount: 40,
            avatar: bundleImage(name: "avatar_02", directory: "Avatar"),
            email: "mason@joke.com",
            password: "mason123",
            isBlock: false,
            followingUserIds: []
        ),
        JC_UserModel(
            userId: "user_003",
            nickname: "Lily",
            gender: .female,
            age: 22,
            bio: "Collecting dad jokes and bad puns.",
            friendCount: 510,
            likeCount: 1200,
            coinCount: 88,
            avatar: bundleImage(name: "avatar_03", directory: "Avatar"),
            email: "lily@joke.com",
            password: "lily123",
            isBlock: false,
            followingUserIds: []
        ),
        JC_UserModel(
            userId: "user_004",
            nickname: "Noah",
            gender: .male,
            age: 26,
            bio: "Why did the scarecrow win an award? He was outstanding.",
            friendCount: 180,
            likeCount: 430,
            coinCount: 15,
            avatar: bundleImage(name: "avatar_04", directory: "Avatar"),
            email: "noah@joke.com",
            password: "noah123",
            isBlock: false,
            followingUserIds: []
        ),
        JC_UserModel(
            userId: "user_005",
            nickname: "Emma",
            gender: .female,
            age: 21,
            bio: "Laugh loud, post often.",
            friendCount: 640,
            likeCount: 2100,
            coinCount: 200,
            avatar: bundleImage(name: "avatar_05", directory: "Avatar"),
            email: "emma@joke.com",
            password: "emma123",
            isBlock: false,
            followingUserIds: []
        ),
        JC_UserModel(
            userId: "user_006",
            nickname: "Leo",
            gender: .male,
            age: 23,
            bio: "Professional meme supplier.",
            friendCount: 275,
            likeCount: 560,
            coinCount: 30,
            avatar: bundleImage(name: "avatar_06", directory: "Avatar"),
            email: "leo@joke.com",
            password: "leo123",
            isBlock: false,
            followingUserIds: []
        )
    ]

    static var allUsers: [JC_UserModel] {
        [resolvedTestUser] + localUsers
    }

    /// 5 位本地用户；若当前登录用户 id 相同则替换为 JC_CurrentUser 最新资料
    static var displayUsers: [JC_UserModel] {
        guard let current = JC_CurrentUser.shared.user else {
            return localUsers
        }
        var users = localUsers
        if let index = users.firstIndex(where: { $0.userId == current.userId }) {
            users[index] = current
        } else if current.userId == testUser.userId {
            return [current] + users
        } else {
            users.insert(current, at: 0)
        }
        return users
    }

    private static var resolvedTestUser: JC_UserModel {
        if let current = JC_CurrentUser.shared.user, current.userId == testUser.userId {
            return current
        }
        return testUser
    }

    static func resolvedUser(userId: String) -> JC_UserModel? {
        var user: JC_UserModel?
        if let current = JC_CurrentUser.shared.user, current.userId == userId {
            user = current
        } else if let local = localUsers.first(where: { $0.userId == userId }) {
            user = local
        } else if userId == testUser.userId {
            user = JC_CurrentUser.shared.user ?? testUser
        }
        guard var resolved = user else { return nil }
        if JC_CurrentUser.shared.isUserBlocked(userId: userId) {
            resolved.isBlock = true
        }
        return resolved
    }

    static func resolvedAuthor(for post: JC_PostModel) -> JC_UserModel {
        resolvedUser(userId: post.author.userId) ?? post.author
    }

    static var posts: [JC_PostModel] {
        JC_PostStore.shared.visiblePosts
    }

    static func makeBootstrapPosts() -> [JC_PostModel] {
        makePosts()
    }

    static var squarePosts: [JC_PostModel] {
        posts
    }

    static var friendPosts: [JC_PostModel] {
        let followingIds = Set(JC_UserModel.current.followingUserIds)
        return posts.filter { followingIds.contains($0.author.userId) }
    }

    static func isFollowing(userId: String, by user: JC_UserModel = .current) -> Bool {
        user.isFollowing(userId: userId)
    }

    static func user(userId: String) -> JC_UserModel? {
        resolvedUser(userId: userId)
    }

    static func posts(for userId: String) -> [JC_PostModel] {
        posts.filter { $0.author.userId == userId }
    }

    static var videoPosts: [JC_PostModel] {
        posts.filter { $0.media.isVideo }
    }

    static var imagePosts: [JC_PostModel] {
        posts.filter { !$0.media.isVideo }
    }

    private static func makePosts() -> [JC_PostModel] {
        var result: [JC_PostModel] = []

        appendVideoPost(
            to: &result,
            author: testUser,
            postId: "post_test_video",
            videoName: "video_01",
            contentIndex: 0,
            likeIndex: 0
        )
        appendImagePost(
            to: &result,
            author: testUser,
            postId: "post_test_img",
            imageNames: ("post_01", "post_02"),
            contentIndex: 0,
            likeIndex: 1
        )

        let localPostPlans: [(videos: (String, String), images: (String, String), contentBase: Int)] = [
            (("video_02", "video_03"), ("post_03", "post_04"), 1),
            (("video_04", "video_05"), ("post_05", "post_06"), 2),
            (("video_06", "video_07"), ("post_07", "post_08"), 3),
            (("video_08", "video_09"), ("post_09", "post_10"), 4),
            (("video_02", "video_04"), ("post_11", "post_12"), 5)
        ]

        for (index, user) in localUsers.enumerated() {
            let plan = localPostPlans[index]
            let userTag = user.userId.replacingOccurrences(of: "user_", with: "")

            appendVideoPost(
                to: &result,
                author: user,
                postId: "post_\(userTag)_video_1",
                videoName: plan.videos.0,
                contentIndex: plan.contentBase,
                likeIndex: index * 3
            )
            appendVideoPost(
                to: &result,
                author: user,
                postId: "post_\(userTag)_video_2",
                videoName: plan.videos.1,
                contentIndex: plan.contentBase + 1,
                likeIndex: index * 3 + 1
            )
            appendImagePost(
                to: &result,
                author: user,
                postId: "post_\(userTag)_img",
                imageNames: plan.images,
                contentIndex: plan.contentBase,
                likeIndex: index * 3 + 2
            )
        }

        return result
    }

    private static let postContents = [
        "This is my first time sharing a joke, I .......",
        "My boss asked why I was late. I said the dream was loading.",
        "I tried to catch fog yesterday. Mist.",
        "Parallel lines have so much in common. It's a shame they'll never meet.",
        "I told my suitcase we're not going on vacation. Now I'm dealing with emotional baggage.",
        "Why don't eggs tell jokes? They'd crack each other up.",
        "I asked the librarian if the library had books on paranoia. She whispered: They're right behind you.",
        "I'm reading a book about anti-gravity. It's impossible to put down."
    ]

    private static let postLikeCounts = ["100W", "56W", "88W", "32W", "120W", "45W", "67W", "91W"]

    private static func appendVideoPost(
        to list: inout [JC_PostModel],
        author: JC_UserModel,
        postId: String,
        videoName: String,
        contentIndex: Int,
        likeIndex: Int
    ) {
        guard let videoURL = bundleVideoURL(name: videoName) else { return }
        list.append(
            JC_PostModel(
                postId: postId,
                author: author,
                content: postContents[contentIndex % postContents.count],
                media: .video(videoURL),
                likeCount: postLikeCounts[likeIndex % postLikeCounts.count],
                dislikeCount: "0",
                isDisliked: false,
                relationText: relationText(for: author),
                isReport: false,
                comments: makeComments(for: author, postId: postId)
            )
        )
    }

    private static func appendImagePost(
        to list: inout [JC_PostModel],
        author: JC_UserModel,
        postId: String,
        imageNames: (String, String),
        contentIndex: Int,
        likeIndex: Int
    ) {
        var images: [UIImage] = []
        if let first = bundleImage(name: imageNames.0, directory: "Post") { images.append(first) }
        if let second = bundleImage(name: imageNames.1, directory: "Post") { images.append(second) }
        guard let media = JC_PostMedia(images: images) else { return }

        list.append(
            JC_PostModel(
                postId: postId,
                author: author,
                content: postContents[contentIndex % postContents.count],
                media: media,
                likeCount: postLikeCounts[likeIndex % postLikeCounts.count],
                dislikeCount: "0",
                isDisliked: false,
                relationText: relationText(for: author),
                isReport: false,
                comments: makeComments(for: author, postId: postId)
            )
        )
    }

    private static func relationText(for author: JC_UserModel) -> String {
        isFollowing(userId: author.userId) ? "Good Friend" : ""
    }

    private static let commentTexts = [
        "I really like your jokes!",
        "This one made my day.",
        "So relatable — keep them coming.",
        "Legendary punchline.",
        "Can't stop laughing at this.",
        "Sharing this with my friends.",
        "Your humor is unmatched.",
        "Need more jokes like this!"
    ]

    private static func makeComments(for author: JC_UserModel, postId: String) -> [JC_PostComment] {
        let candidates = allUsers.filter { $0.userId != author.userId }
        guard !candidates.isEmpty else { return [] }

        let sorted = candidates.sorted {
            ($0.userId + postId).hashValue < ($1.userId + postId).hashValue
        }
        let desiredCount = 2 + abs(postId.hashValue) % 2
        let count = min(desiredCount, sorted.count)

        return sorted.prefix(count).enumerated().map { index, commenter in
            let textIndex = abs((postId + commenter.userId + "\(index)").hashValue) % commentTexts.count
            return JC_PostComment(
                commentId: "seed_\(postId)_\(commenter.userId)",
                userId: commenter.userId,
                userName: commenter.nickname,
                content: commentTexts[textIndex],
                avatar: commenter.avatar,
                isUserAdded: false
            )
        }
    }

    private static func bundleImage(name: String, directory: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: directory) {
            return UIImage(contentsOfFile: path)
        }
        return UIImage(named: name)
    }

    private static func bundleVideoURL(name: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp4", subdirectory: "Videos") {
            return url
        }
        return Bundle.main.url(forResource: name, withExtension: "mp4")
    }

}
