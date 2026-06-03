//
//  JC_HomeVideoItem.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import Foundation

struct JC_HomeVideoItem {
    let videoURL: URL
    let jokeText: String
    let likeCount: String
    let commentCount: String
}

enum JC_HomeVideoProvider {

    static func loadItems() -> [JC_HomeVideoItem] {
        JC_UserData.videoPosts.compactMap { post in
            guard let videoURL = post.media.videoURL else { return nil }
            return JC_HomeVideoItem(
                videoURL: videoURL,
                jokeText: post.content,
                likeCount: post.likeCount,
                commentCount: "\(post.comments.count)"
            )
        }
    }

}
