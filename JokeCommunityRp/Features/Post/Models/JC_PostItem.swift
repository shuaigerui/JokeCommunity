//
//  JC_PostItem.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

struct JC_PostItem {
    let postId: String
    let authorUserId: String
    let userName: String
    let age: String
    let gender: JC_UserGender
    let avatar: UIImage?
    let content: String
    let images: [UIImage?]
    let likeCount: String
    let dislikeCount: String
    let isLiked: Bool
    let isDisliked: Bool
    let showAddFriend: Bool
}
