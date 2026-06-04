//
//  JC_PostModel.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit

enum JC_PostMedia {
    case video(URL)
    case images([UIImage])

    init?(videoURL: URL) {
        self = .video(videoURL)
    }

    init?(images: [UIImage]) {
        guard (1...2).contains(images.count) else { return nil }
        self = .images(images)
    }

    var isVideo: Bool {
        if case .video = self { return true }
        return false
    }

    var images: [UIImage] {
        if case .images(let list) = self { return list }
        return []
    }

    var videoURL: URL? {
        if case .video(let url) = self { return url }
        return nil
    }
}

struct JC_PostModel {

    var postId: String
    var author: JC_UserModel
    var content: String
    var media: JC_PostMedia
    var likeCount: String
    var dislikeCount: String
    var isDisliked: Bool
    var relationText: String
    var isReport: Bool
    var comments: [JC_PostComment]

    static let sampleImagePost = JC_PostModel(
        postId: "post_001",
        author: .current,
        content: "This is my first time sharing a joke, I .......",
        media: .images([]),
        likeCount: "100W",
        dislikeCount: "0",
        isDisliked: false,
        relationText: "Good Friend",
        isReport: false,
        comments: [
            JC_PostComment(
                commentId: "sample_1",
                userId: "user_002",
                userName: "Angela",
                content: "I really like your jokes",
                avatar: nil,
                isUserAdded: false
            )
        ]
    )

}
