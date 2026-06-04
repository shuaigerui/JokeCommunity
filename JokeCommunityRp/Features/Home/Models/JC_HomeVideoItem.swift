//
//  JC_HomeVideoItem.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

struct JC_HomeVideoItem {
    let postId: String
    let authorUserId: String
    let avatar: UIImage?
    let videoURL: URL
    let jokeText: String
    let likeCount: String
    let dislikeCount: String
    let commentCount: String
    let isLiked: Bool
    let isDisliked: Bool
}

enum JC_HomeVideoProvider {

    static func loadItems() -> [JC_HomeVideoItem] {
        JC_UserData.videoPosts.compactMap { post in
            guard let videoURL = post.media.videoURL else { return nil }
            let author = JC_UserData.resolvedAuthor(for: post)
            return JC_HomeVideoItem(
                postId: post.postId,
                authorUserId: author.userId,
                avatar: author.avatar,
                videoURL: videoURL,
                jokeText: post.content,
                likeCount: post.likeCount,
                dislikeCount: post.dislikeCount,
                commentCount: "\(post.comments.count)",
                isLiked: JC_PostStore.shared.isLiked(postId: post.postId),
                isDisliked: JC_PostStore.shared.isDisliked(postId: post.postId)
            )
        }
    }

}
